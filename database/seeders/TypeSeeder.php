<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Type;

class TypeSeeder extends Seeder
{
    private function create(string $headType, string $name, string $code = '')
    {
        Type::create([
            'type_id'   => Type::whereName($headType)->first() ? Type::whereName($headType)->first()->id : 0,
            'name'      => $name,
            'code'      => $code
        ]);
    }

    public function run()
    {
        $this->create('', 'PlayerPuppet', 'local playerPuppet = Game:GetPlayer()');
    }
}
