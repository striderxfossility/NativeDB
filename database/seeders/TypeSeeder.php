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

        //dump($data);
    }
}
