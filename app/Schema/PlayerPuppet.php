<?php

namespace App\Schema;

use App\Models\Type;
use App\Models\Field;

class PlayerPuppet extends BaseSchema
{
    public function __construct()
    {
        $this->headType   = Type::getType('ScriptedPuppet');
        $this->name       = 'PlayerPuppet';
        $this->code       = 'local value = Game:GetPlayer()';
        $this->fields     = 
        [
            Field::getArray('quickSlotsManager', 'handle', 'QuickSlotsManager', true),
            Field::getArray('inspectionComponent', 'handle', 'InspectionComponent', true),
            Field::getArray('Phone', 'handle', 'PlayerPhone', false),
            Field::getArray('fppCameraComponent', 'handle', 'gameFPPCameraComponent', true),
            Field::getArray('primaryTargetingComponent', 'handle', 'gameTargetingComponent', true),
            Field::getArray('DEBUG_Visualizer', 'handle', 'DEBUG_VisualizerComponent', false),
            Field::getArray('Debug_DamageInputRec', 'handle', 'DEBUG_DamageInputReceiver', true),
            Field::getArray('highDamageThreshold', 'Float', '', false),
        ];
    }
}