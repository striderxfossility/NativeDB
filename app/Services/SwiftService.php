<?php

namespace App\Services;

use App\Models\Type;
use App\Models\Prop;
use App\Models\Enum;
use App\Models\Bitfield;
use App\Models\Method;
use App\Models\Param;
use App\Models\Code;

class SwiftService 
{
    public static function get(string $file) {
        $lines      = preg_split("/\r\n|\n|\r/", $file);
        $functions  = self::getFunctions($lines);
        $dataCodes  = [];
        $time       = now()->toDateTimeString();

        $types = Type::whereIn('name', $functions[1])->with('methods')->with('methods.code')->get();

        foreach($types as $type)
        {
            foreach($type->methods as $method)
            {
                foreach($functions[0] as $key => $value) {
                    if (stripos(strtolower($key), $method->shortName) !== false) {
                        $strBuilder = '';

                        for ($i=0; $i < count($functions[0][$key]) - 1; $i++) { 
                            $strBuilder .= $functions[0][$key][$i] . "\n";
                        }

                        if($method->code == null) {
                            $dataCodes[] = [
                                'type'          => $type->name,
                                'method'        => $method->fullName,
                                'native'        => $strBuilder,
                                'created_at'    => $time,
                                'updated_at'    => $time,
                            ];
                        } else {
                            $method->code->native = $strBuilder;
                            $method->code->update();
                        }

                        break;
                    }
                }
            }
        }

        $chunks = array_chunk($dataCodes, 1000);
        foreach($chunks as $chunk)
        {
            Code::insert($chunk);
        }
    }

    private static function getFunctions($lines) {
        $functions      = [];
        $foundClass     = false;
        $classFunction  = "";
        $class          = null;
        $classes        = [];

        for ($i=0; $i < count($lines); $i++) { 
            if(str_contains($lines[$i], ' class ')) {
                if (preg_match('/class (.*?) extends/', $lines[$i], $match) == 1) {
                    $class = $match[1];
                    $classes[] = $class;
                }
            }
            
            if(str_contains($lines[$i], ' func ')) {
                $foundClass = true;
                $classFunction = $lines[$i];
                $functions[$lines[$i]] = [$lines[$i] . 'test'];
            } else {
                if($foundClass == true) {
                    if(array_key_exists($i + 1, $lines)) {
                        if(trim($lines[$i]) == '}' && trim($lines[$i + 1]) == '') {
                            $foundClass = false;
                            $functions[$classFunction][] = $lines[$i];
                            $functions[$classFunction][] = $class;
                        } else {
                            $functions[$classFunction][] = $lines[$i];
                        }
                    } else {
                        $foundClass = false;
                    }
                }
            }
        }

        return [$functions, $classes];
    }
}