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
            $FlatToExtract  = 0;
            $timestamp      = now()->toDateTimeString();

            if($arr == null) {
                $this->command->error("tweakdb.json is not a valid json file");
                dump(json_last_error());
            } else {
                $y = 0;
                $countAmounts = count($arr['flat']['keys' . $FlatToExtract]);
                foreach($arr['flat']['keys' . $FlatToExtract] as $key => $value)
                {
                    $value      = json_encode($arr['flat']['values' . $FlatToExtract][$value]);
                    $headGroup  = 0;
                    $tweakValue = TweakValue::whereName($key)->first();

                    if ($tweakValue == null) {
                        $this->command->info('Extracting => ' . $y . '/' . $countAmounts . ' tweak');
                        $groups = explode('.', $key);
                        for ($x=0; $x < count($groups) - 1; $x++) { 
                            $tweakGroup = TweakGroup::whereName($groups[$x])->whereTweakGroupId($headGroup)->first();

                            if($tweakGroup != null) {
                                $headGroup = $tweakGroup->id;
                            } else {
                                $headGroup = TweakGroup::insertGetId([
                                    'tweak_group_id' => $headGroup,
                                    'name'           => $groups[$x],
                                    "created_at"     => $timestamp,
                                    "updated_at"     => $timestamp,
                                ]);
                            }
                        }

                        $dataTweaks[] = [
                            'tweak_group_id'    => $headGroup,
                            'name'              => $key,
                            'value'             => $value
                        ];
                    } else {
                        $this->command->warn('Skipped => ' . $y . '/' . $countAmounts . ' tweak');
                        $tweakValue->value = $value;
                        $tweakValue->update();
                    }

                    $y++;
                }

                $chunks = array_chunk($dataTweaks, 5000);
                foreach($chunks as $chunk)
                {
                    TweakValue::insert($chunk);
                }
            }
        }
    }
}