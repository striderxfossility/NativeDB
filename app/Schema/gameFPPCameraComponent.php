<?php

namespace App\Schema;

use App\Models\Type;
use App\Models\Field;

class gameFPPCameraComponent extends BaseSchema
{
    public function __construct()
    {
        $this->headType   = Type::getType('gameCameraComponent');
        $this->name       = 'gameFPPCameraComponent';
        $this->code       = 'local value = Game:GetPlayer().gameFPPCameraComponent';
        $this->fields     = 
        [
            Field::getArray('pitchMin', ' Float', '', false),
            Field::getArray('pitchMax', ' Float', '', false),
            Field::getArray('yawMaxLeft', ' Float', '', false),
            Field::getArray('yawMaxRight', ' Float', '', false),
            Field::getArray('headingLocked', ' Bool', '', false),
            Field::getArray('sensitivityMultX', ' Float', '', false),
            Field::getArray('sensitivityMultY', ' Float', '', false),
            Field::getArray('timeDilationCurveName', ' CName', '', false)
        ];
    }
}