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
        $jsonString = file_get_contents(base_path('public/dumps/classes/PlayerPuppet.json'));

        $data = json_decode($jsonString, true);

        $type = Type::create([
            "parent"    => $data['parent'],
            "name"      => $data['name'],
            "flags"     => $data['flags']
        ]);

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
    }
}
