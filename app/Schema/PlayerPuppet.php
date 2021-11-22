<?php

namespace App\Schema;

use App\Models\Type;
use App\Models\Field;
use App\Models\Method;

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
            Field::getArray('medDamageThreshold', 'Float', '', false),
            Field::getArray('lowDamageThreshold', 'Float', '', false),
            Field::getArray('meleeHighDamageThreshold', 'Float', '', false),
            Field::getArray('meleeMedDamageThreshold', 'Float', '', false),
            Field::getArray('meleeLowDamageThreshold', 'Float', '', false),
            Field::getArray('explosionHighDamageThreshold', 'Float', '', false),
            Field::getArray('explosionMedDamageThreshold', 'Float', '', false),
            Field::getArray('explosionLowDamageThreshold', 'Float', '', false),
            Field::getArray('effectTimeStamp', 'Float', '', false),
            Field::getArray('curInventoryWeight', 'Float', '', false),
            Field::getArray('healthVfxBlackboard', 'handle', 'worldEffectBlackboard', false),
            Field::getArray('laserTargettingVfxBlackboard', 'handle', 'worldEffectBlackboard', false),
            Field::getArray('itemLogBlackboard', 'whandle', 'gameIBlackboard', false),
            Field::getArray('interactionDataListener', 'handle', 'redCallbackObject', false),
            Field::getArray('popupIsModalListener', 'handle', 'redCallbackObject', false),
            Field::getArray('uiVendorContextListener', 'handle', 'redCallbackObject', false),
            Field::getArray('uiRadialContextistener', 'handle', 'redCallbackObject', false),
            Field::getArray('contactsActiveListener', 'handle', 'redCallbackObject', false),
            Field::getArray('currentVisibleTargetListener', 'handle', 'redCallbackObject', false),
            Field::getArray('lastScanTarget', 'whandle', 'gameObject', false),
            Field::getArray('meleeSelectInputProcessed', 'Bool', '', false),
            Field::getArray('waitingForDelayEvent', 'Bool', '', true),
            Field::getArray('randomizedTime', 'Float', '', true),
            Field::getArray('isResetting', 'Bool', '', true),
            Field::getArray('delayEventID', 'gameDelayID', '', true),
            Field::getArray('resetTickID', 'gameDelayID', '', true),
            Field::getArray('katanaAnimProgression', 'Float', '', true),
            Field::getArray('coverModifierActive', 'Bool', '', true),
            Field::getArray('workspotDamageReductionActive', 'Bool', '', true),
            Field::getArray('workspotVisibilityReductionActive', 'Bool', '', true),
            Field::getArray('currentPlayerWorkspotTags', 'array', 'CName', true),
            Field::getArray('incapacitated', 'Bool', '', true),
            Field::getArray('remoteMappinId', 'gameNewMappinID', '', true),
            Field::getArray('CPOMissionDataState', 'handle', 'CPOMissionDataState', false),
            Field::getArray('CPOMissionDataBbId', 'handle', 'redCallbackObject', true),
            Field::getArray('visibilityListener', 'handle', 'VisibilityStatListener', true),
            Field::getArray('secondHeartListener', 'handle', 'SecondHeartStatListener', true),
            Field::getArray('armorStatListener', 'handle', 'ArmorStatListener', true),
            Field::getArray('healthStatListener', 'handle', 'HealthStatListener', true),
            Field::getArray('oxygenStatListener', 'handle', 'OxygenStatListener', true),
            Field::getArray('aimAssistListener', 'handle', 'AimAssistSettingsListener', true),
            Field::getArray('autoRevealListener', 'handle', 'AutoRevealStatListener', true),
            Field::getArray('isTalkingOnPhone', 'Bool', '', true),
            Field::getArray('DataDamageUpdateID', 'gameDelayID', '', true),
            Field::getArray('playerAttachedCallbackID', 'Uint32', '', true),
            Field::getArray('playerDetachedCallbackID', 'Uint32', '', true),
            Field::getArray('callbackHandles', 'array', '', true),
            Field::getArray('numberOfCombatants', 'Int32', '', true),
            Field::getArray('equipmentMeshOverlayEffectName', 'CName', '', true),
            Field::getArray('equipmentMeshOverlayEffectTag', 'CName', '', true),
            Field::getArray('equipmentMeshOverlaySlots', 'array', 'TweakDBID', true),
            Field::getArray('coverVisibilityPerkBlocked', 'Bool', '', true),
            Field::getArray('behindCover', 'Bool', '', true),
            Field::getArray('inCombat', 'Bool', '', true),
            Field::getArray('hasBeenDetected', 'Bool', '', true),
            Field::getArray('inCrouch', 'Bool', '', true),
            Field::getArray('gunshotRange', 'Float', '', true),
            Field::getArray('explosionRange', 'Float', '', true),
            Field::getArray('nextBufferModifier', 'Int32', '', true),
            Field::getArray('attackingNetrunnerID', 'entEntityID', '', true),
            Field::getArray('NPCDeathInstigator', 'whandle', 'NPCPuppet', true),
            Field::getArray('bestTargettingWeapon', 'whandle', 'gameweaponObject', true),
            Field::getArray('bestTargettingDot', 'Float', '', true),
            Field::getArray('targettingEnemies', 'Int32', '', true),
            Field::getArray('isAimingAtFriendly', 'Bool', '', true),
            Field::getArray('isAimingAtChild', 'Bool', '', true),
            Field::getArray('coverRecordID', 'TweakDBID', '', true),
            Field::getArray('damageReductionRecordID', 'TweakDBID', '', true),
            Field::getArray('visReductionRecordID', 'TweakDBID', '', true),
            Field::getArray('lastDmgInflicted', 'EngineTime', '', true),
            Field::getArray('critHealthRumblePlayed', 'Bool', '', true),
            Field::getArray('critHealthRumbleDurationID', 'gameDelayID', '', true),
            Field::getArray('staminaListener', 'handle', 'StaminaListener', true),
            Field::getArray('memoryListener', 'handle', 'MemoryListener', true),
            Field::getArray('securityAreaTypeE3HACK', 'ESecurityAreaType', '', false),
            Field::getArray('overlappedSecurityZones', 'array', 'gamePersistentID', true),
            Field::getArray('interestingFacts', 'InterestingFacts', '', true),
            Field::getArray('interestingFactsListenersIds', 'InterestingFactsListenersIds', '', true),
            Field::getArray('interestingFactsListenersFunctions', 'InterestingFactsListenersFunctions', '', true),
            Field::getArray('visionModeController', 'handle', 'PlayerVisionModeController', true),
            Field::getArray('combatController', 'handle', 'PlayerCombatController', true),
            Field::getArray('cachedGameplayRestrictions', 'array', 'TweakDBID', true),
            Field::getArray('delayEndGracePeriodAfterSpawnEventID', 'gameDelayID', '', true),
            Field::getArray('bossThatTargetsPlayer', 'entEntityID', '', true),
            Field::getArray('choiceTokenTextLayerId', 'Uint32', '', true),
            Field::getArray('choiceTokenTextDrawn', 'Bool', '', true),
            Field::getArray('bossThatTargetsPlayer', ' entEntityID', '', true),
            Field::getArray('choiceTokenTextLayerId', ' Uint32', '', true),
            Field::getArray('choiceTokenTextDrawn', ' Bool', '', true)
        ];
        $this->methods = 
        [
            Method::getArray('CanApplyBreathingEffect', 'player : whandle:PlayerPuppet', 'Bool', 0, true)
        ];
    }
}