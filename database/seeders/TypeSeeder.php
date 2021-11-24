<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Type;
use App\Models\Prop;
use App\Models\Method;

class TypeSeeder extends Seeder
{
    public function run()
    {
        $files = scandir(base_path('public/dumps/classes/'));
        $countFiles = count($files);

        dump("Start importing classes");

        for ($i=0; $i < $countFiles; $i++) { 
            try {
                $start = microtime(true);
                $fp = fopen(base_path('public/dumps/classes/' . $files[$i]), 'r');
                
                $parent = '';
                $name = '';
                $flags = 0;

                for ($x = 0; $x < 4; $x++) {
                    if (feof($fp)) {
                        echo 'EOF reached';
                        break;
                    }

                    $line = fgets($fp);

                    if(str_contains($line, 'parent')) {
                        $line = explode(':', $line)[1];
                        $line = str_replace('"', '', $line);
                        $line = str_replace(',', '', $line);
                        $parent = trim($line);
                    }

                    if(str_contains($line, 'name')) {
                        $line = explode(':', $line)[1];
                        $line = str_replace('"', '', $line);
                        $line = str_replace(',', '', $line);
                        $name = trim($line);
                    }

                    if(str_contains($line, 'flags')) {
                        $line = explode(':', $line)[1];
                        $line = str_replace('"', '', $line);
                        $line = str_replace(',', '', $line);
                        $flags = trim($line);
                    }
                }

                fclose($fp);

                $dataTypes[] = [
                    "parent"        => $parent,
                    "name"          => $name,
                    "flags"         => $flags,
                    "created_at"    => now()->toDateTimeString(),
                    "updated_at"    => now()->toDateTimeString(),
                ];

                /*
                if(isset($data['props'])) {
                    foreach($data['props'] as $prop)
                    {
                        $explode = explode(":", $prop['type']);

                        $dataProps[] = [
                            "type_id"     => $type->id,
                            "name"        => $prop['name'],
                            "return"      => isset($explode[0]) ? $explode[0] : '',
                            "return_type" => isset($explode[1]) ? $explode[1] : '',
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
                        $dataMethods[] = [
                            "type_id"      => $type->id,
                            "fullName"     => $methods['fullName'],
                            "shortName"    => $methods['shortName'],
                            "return"       => isset($methods['return']) ? $methods['return']['type'] : '',
                            "return_flags" => isset($methods['return']) ? $methods['return']['flags'] : '',
                            "flags"        => $prop['flags'],
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
                }*/

                //dump($i . "/" . $countFiles . " : " . microtime(true) - $start);
            } catch (\Exception $e) {
                dump($e->getMessage());
            }
        }

        $chunks = array_chunk($dataTypes, 1000);
        foreach($chunks as $chunk)
        {
            Type::insert($chunk);
        }

        dump("Finished");
    }
}
