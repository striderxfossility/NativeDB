<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Services\SwiftService;

class SwiftSeeder extends Seeder
{
    public function run()
    {
        $this->command->comment("Start collecting files");

        $files = $this->find_all_files(base_path('public/adamsmasher'));
        $count = count($files);

        $this->command->comment("Found " . $count . " files");

        for ($i=0; $i < $count; $i++) { 
            $content = file_get_contents($files[$i], 'r');

            SwiftService::get($content);

            $this->command->info($i . '/' . $count . ' files extracted, (' . $files[$i] . ')');
        }
    }

    private function find_all_files($dir)
    {
        $root = scandir($dir);
        foreach($root as $value)
        {
            if($value === '.' || $value === '..') {continue;}
            if(is_file("$dir/$value")) {$result[]="$dir/$value";continue;}
            foreach($this->find_all_files("$dir/$value") as $value)
            {
                $result[]=$value;
            }
        }
        return $result;
    }
}