<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Type;
use App\Schema\BaseSchema;
use App\Models\Field;

class TypeSeeder extends Seeder
{
    private function create(BaseSchema $schema)
    {
        $type = Type::create([
            'type_id'   => $schema->headType,
            'name'      => $schema->name,
            'code'      => $schema->code
        ]);

        for ($i=0; $i < count($schema->fields); $i++) { 
            $schema->fields[$i]['type_id'] = $type->id;
        }

        $chunks = array_chunk($schema->fields, 1000);
        foreach($chunks as $chunk)
        {
            Field::insert($chunk);
        }
        
    }

    public function run()
    {
        $this->create(new \App\Schema\gameFPPCameraComponent());
        $this->create(new \App\Schema\PlayerPuppet());
    }
}
