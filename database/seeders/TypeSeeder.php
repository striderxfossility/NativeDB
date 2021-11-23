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

            $dataProp[] = [
                "type_id"     => $type->id,
                "name"        => $prop['name'],
                "return"      => isset($explode[0]) ? $explode[0] : '',
                "return_type" => isset($explode[1]) ? $explode[1] : '',
                "flags"       => $prop['flags'],
                'created_at'  => now()->toDateTimeString(),
                'updated_at'  => now()->toDateTimeString(),
            ];
        }

        $chunks = array_chunk($dataProp, 1000);
        foreach($chunks as $chunk)
        {
            Prop::insert($chunk);
        }
    }
}
