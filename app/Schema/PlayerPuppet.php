<?php

namespace App\Schema;

use App\Models\Type;

class PlayerPuppet extends BaseSchema
{
    public function __construct()
    {
        $this->headType   = Type::getType('ScriptedPuppet');
        $this->name       = 'PlayerPuppet';
        $this->code       = 'local value = Game:GetPlayer()';
        $this->fields     = 
        [
            [
                'name'          => 'quickSlotsManager',
                'return'        => 'handle',
                'return_type'   => Type::getType('QuickSlotsManager'),
                'code'          => $this->code . '.quickSlotsManager',
                'private'       => true
            ]
        ];
    }
}