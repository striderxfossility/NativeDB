<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Type;
use App\Schema\BaseSchema;
use App\Schema\PlayerPuppet;

class TypeSeeder extends Seeder
{
    private function create(BaseSchema $schema)
    {
        $type = Type::create([
            'type_id'   => $schema->headType,
            'name'      => $schema->name,
            'code'      => $schema->code
        ]);

        $type->fields()->createMany($schema->fields);
    }

    public function run()
    {
        $this->create(new PlayerPuppet());
    }
}
