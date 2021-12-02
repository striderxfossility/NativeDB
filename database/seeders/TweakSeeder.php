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
use App\Models\TweakGroup;
use App\Models\TweakValue;

class TweakSeeder extends Seeder
{
    public function run()
    {
        if (!file_exists('public/tweakdb.json')) {
            dump("Cannot find tweakdb.json, upload it to public dir");
            $this->command->error("Cannot find tweakdb.json, upload it to public dir");
        } else {
            $string         = file_get_contents(base_path('public/tweakdb.json'));
            $string         = preg_replace('/([0-9^]+):/', '"$1":', $string);
            $string         = str_replace('\\', '/', $string);
            $arr            = json_decode($string, true);
            $amountOfFlats  = 21;
            $timestamp      = now()->toDateTimeString();

            if($arr == null) {
                $this->command->error("tweakdb.json is not a valid json file");
                dump(json_last_error());
            } else {
                for ($i=0; $i < $amountOfFlats; $i++) { 
                    $this->command->info('Start ' . $i . '/' . $amountOfFlats . ' tweakFlats extracting');
                    $y = 0;
                    $countAmounts = count($arr['flat']['keys' . $i]);
                    foreach($arr['flat']['keys' . $i] as $key => $value)
                    {
                        $value      = json_encode($arr['flat']['values' . $i][$value]);
                        $headGroup  = '';
                        //$tweakValue = TweakValue::whereName($key)->first();

                        //if ($tweakValue == null) {
                        $this->command->info('Start (' . $i . '/' . $amountOfFlats . ') => ' . $y . '/' . $countAmounts . ' tweaks extracting');
                        $groups = explode('.', $key);
                        for ($x=0; $x < count($groups) - 1; $x++) { 
                            $dataGroups[] = [
                                'tweak_group_name'  => $headGroup,
                                'name'              => $groups[$x],
                                "created_at"        => $timestamp,
                                "updated_at"        => $timestamp,
                            ];
                            $headGroup = $groups[$x];
                        }

                        $dataTweaks[] = [
                            "name"              => $key,
                            "value"             => $value,
                            "created_at"        => $timestamp,
                            "updated_at"        => $timestamp,
                        ];
                        //} else {
                        //    $this->command->warn('Skipped (' . $i . '/' . $amountOfFlats . ') => ' . $y . '/' . $countAmounts . ' tweaks extracting');
                        //    $tweakValue->value = $value;
                        //    $tweakValue->update();
                        //}

                        $y++;
                    }
                    break;
                }

                $chunks = array_chunk($dataTweaks, 5000);
                foreach($chunks as $chunk)
                {
                    TweakValue::insert($chunk);
                }

                $dataGroups = array_unique($dataGroups, SORT_REGULAR);

                $chunks = array_chunk($dataGroups, 5000);
                foreach($chunks as $chunk)
                {
                    TweakGroup::insert($chunk);
                }
            }
        }
    }
}