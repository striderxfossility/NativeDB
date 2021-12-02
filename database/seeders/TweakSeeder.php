<?php

/*
IMPORTANT

REPLACE 
status_drunk_level_1:BaseStatusEffect.Drunk                    = status_drunk_level_1FIXJB:BaseStatusEffect.Drunk
status_drunk_level_2:BaseStatusEffect.Drunk                    = status_drunk_level_2FIXJB:BaseStatusEffect.Drunk
status_drunk_level_3:BaseStatusEffect.Drunk                    = status_drunk_level_3FIXJB:BaseStatusEffect.Drunk
johnny_silverhand_replacer_clean_2020:silverhand_clean_2020    = johnny_silverhand_replacer_clean_2020FIXJB:silverhand_clean_2020

REPLACE
"flat": {
    "values0": [],
    "keys0": [],
    "values1": [],
    "keys1": [], etc...
}
*/

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class TweakSeeder extends Seeder
{
    public function run()
    {
        $timestamp  = now()->toDateTimeString();
        
        if (!file_exists('public/tweakdb.json')) {
            $this->command->error("Cannot find tweakdb.json, upload it to public dir");
        } else {
            $string = file_get_contents(base_path('public/tweakdb.json'));
            $string = preg_replace('/([0-9^]+):/gm', '"$1":', $string);

            $json   = json_decode($string, true);

            if($json == null) {
                $this->command->error("tweakdb.json is not a valid json file");
                dump(json_last_error());
            } else {
                dump($json);
            }
        }
    }
}