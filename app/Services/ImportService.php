<?php

namespace App\Services;

use App\Models\Type;
use App\Models\Prop;
use App\Models\Method;

class ImportService 
{
    public static function get(Type $type) {

        if($type->cached)
            return $type;

        $jsonString = file_get_contents(base_path('public/dumps/classes/'. $type->name .'.json'));

        $data = json_decode($jsonString, true);

        if(isset($data['props'])) {
            foreach($data['props'] as $prop)
            {
                $explode = explode(":", $prop['type']);
                $return_type = '';

                if(isset($explode[1])) {
                    
                    if($explode[0] == 'array') {
                        $rem = $explode[1];
                        $explode[0] = $explode[0] . ':' .  $rem;
                        if(isset($explode[2])) 
                            $explode[1] = $explode[2];
                        else {
                            if(Type::getType($rem) != 0)
                                $explode[1] = Type::getType($rem);
                            else
                                $explode[1] = '';
                        }
                    }

                    $return_type = Type::getType($explode[1]);

                    if($return_type == '0')
                        $return_type = $explode[1];
                }

                $dataProps[] = [
                    "type_id"     => $type->id,
                    "name"        => $prop['name'],
                    "return"      => isset($explode[0]) ? $explode[0] : '',
                    "return_type" => $return_type,
                    "flags"       => $prop['flags'],
                    'created_at'  => now()->toDateTimeString(),
                    'updated_at'  => now()->toDateTimeString(),
                ];
            }

            $chunks = array_chunk($dataProps, 1000);
            foreach($chunks as $chunk)
            {
                Prop::insert($chunk);
            }
        }

        if(isset($data['funcs'])) {
            foreach($data['funcs'] as $methods)
            {
                $return_type = 0;

                if(isset($methods['return'])) {
                    if(str_contains($methods['return']['type'], 'array')) {
                        $explode = explode(":", $methods['return']['type']);
                        $return_type = Type::getType($explode[1]);
                    } else {
                        $return_type = Type::getType($methods['return']['type']);
                    }

                    if(str_contains($methods['return']['type'], 'handle')) {
                        $explode = explode(":", $methods['return']['type']);
                        $return_type = Type::getType($explode[1]);
                    }
                }

                $dataMethods[] = [
                    "type_id"      => $type->id,
                    "fullName"     => $methods['fullName'],
                    "shortName"    => $methods['shortName'],
                    "return"       => isset($methods['return']) ? $methods['return']['type'] : '',
                    "return_flags" => isset($methods['return']) ? $methods['return']['flags'] : '',
                    "return_type"  => $return_type,
                    "flags"        => $methods['flags'],
                    "params"       => isset($methods['params']) ? json_encode($methods['params']) : '',
                    'created_at'   => now()->toDateTimeString(),
                    'updated_at'   => now()->toDateTimeString(),
                ];
            }

            $chunks = array_chunk($dataMethods, 1000);
            foreach($chunks as $chunk)
            {
                Method::insert($chunk);
            }
        }

        $type->type_id  = Type::getType($type->parent);
        $type->cached   = true;

        $type->save();

        return $type;
    }
}