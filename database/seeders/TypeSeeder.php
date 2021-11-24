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
        $files      = scandir(base_path('public/dumps/classes/'));
        $countFiles = count($files);
        $timestamp  = now()->toDateTimeString();

        dump("Start importing classes");

        for ($i=0; $i < $countFiles; $i++) { 
            try {
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
                    "created_at"    => $timestamp,
                    "updated_at"    => $timestamp,
                ];

            } catch (\Exception $e) {
                dump($e->getMessage());
            }
        }

        $chunks = array_chunk($dataTypes, 5000);
        foreach($chunks as $chunk)
        {
            Type::insert($chunk);
        }

        dump("Finished");
    }
}
