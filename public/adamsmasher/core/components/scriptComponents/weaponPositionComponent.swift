
public class WeaponPositionComponent extends ScriptableComponent {

  private let m_playerPuppet: wref<PlayerPuppet>;

  private let m_tweakPoseState: TweakWeaponPose;

  private let m_tweakPosition: Bool;

  private let m_tweakRotation: Bool;

  private let m_fineTuneWeaponPose: Bool;

  private let m_positionSensitivity: Float;

  private let m_positionSensitivityFineTuning: Float;

  private let m_rotationSensitivity: Float;

  private let m_rotationSensitivityFineTuning: Float;

  private let m_visionSwitch: Bool;

  private let m_visSys: ref<VisionModeSystem>;

  private let m_weaponPosDeltaX: Float;

  private let m_weaponPosDeltaY: Float;

  private let m_weaponPosDeltaZ: Float;

  private let m_weaponRotDeltaX: Float;

  private let m_weaponRotDeltaY: Float;

  private let m_weaponRotDeltaZ: Float;

  private let m_weaponPosVec: Vector4;

  private let m_weaponRotVec: Vector4;

  private let m_weaponAimPosVec: Vector4;

  private let m_weaponAimRotVec: Vector4;

  private let m_weaponPosOffsetFromInput: Vector4;

  private let m_weaponRotOffsetFromInput: Vector4;

  private let m_weaponAimPosOffsetFromInput: Vector4;

  private let m_weaponAimRotOffsetFromInput: Vector4;

  private let m_cameraStandHeight: Float;

  private let m_cameraCrouchHeight: Float;

  private let m_cameraResetPitch: Bool;

  private let m_cameraHeightOffset: Float;

  private let UILayerID0: Uint32;

  private let UILayerID1: Uint32;

  private let UILayerID2: Uint32;

  private let UILayerID3: Uint32;

  private final func GetBlackboardIntVariable(id: BlackboardID_Int) -> Int32 {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(this.m_playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.GetInt(id);
  }

  private final func SetBlackboardIntVariable(id: BlackboardID_Int, value: Int32) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(this.m_playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.SetInt(id, value);
  }

  private final func GetBlackboardBoolVariable(id: BlackboardID_Bool) -> Bool {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(this.m_playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.GetBool(id);
  }

  private final func SetBlackboardBoolVariable(id: BlackboardID_Bool, varValue: Bool) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(this.m_playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.SetBool(id, varValue);
  }

  private final func OnGameAttach() -> Void {
    Log("WeaponPositionComponent: Attach");
    this.m_playerPuppet = this.GetOwner() as PlayerPuppet;
    this.GetOwner().RegisterInputListener(this, n"Debug_ModifyWeaponPosition");
    this.GetOwner().RegisterInputListener(this, n"Debug_ModifyWeaponRotation");
    this.GetOwner().RegisterInputListener(this, n"Debug_ResetWeaponPosition");
    this.GetOwner().RegisterInputListener(this, n"Debug_FineTuneWeaponPose");
    this.GetOwner().RegisterInputListener(this, n"DebugWeaponPosX");
    this.GetOwner().RegisterInputListener(this, n"DebugWeaponPosY");
    this.GetOwner().RegisterInputListener(this, n"DebugWeaponPosZ");
    this.GetOwner().RegisterInputListener(this, n"DebugWeaponRotX");
    this.GetOwner().RegisterInputListener(this, n"DebugWeaponRotY");
    this.GetOwner().RegisterInputListener(this, n"DebugWeaponRotZ");
    this.GetOwner().RegisterInputListener(this, n"Debug_ToggleFocusMode");
    this.ResetData();
  }

  private final func OnUpdate(deltaTime: Float) -> Void {
    this.ClearDebugInfo();
    this.UpdateTweakDBParams();
    this.UpdateData();
    if this.m_tweakPosition || this.m_tweakRotation {
      this.UpdateWeaponPositionDataFromInput();
    };
    this.ResetDeltas();
    this.m_weaponAimPosVec += this.m_weaponAimPosOffsetFromInput;
    this.m_weaponAimRotVec += this.m_weaponAimRotOffsetFromInput;
    this.m_weaponPosVec += this.m_weaponPosOffsetFromInput;
    this.m_weaponRotVec += this.m_weaponRotOffsetFromInput;
    this.SendData();
    if this.ShouldDisplayDebugInfo() {
      this.UpdateDebugInfo();
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetName(action), n"Debug_ModifyWeaponPosition") {
      if ListenerAction.IsButtonJustPressed(action) {
        this.m_tweakPosition = true;
      } else {
        if ListenerAction.IsButtonJustReleased(action) {
          this.m_tweakPosition = false;
        };
      };
    };
    if Equals(ListenerAction.GetName(action), n"Debug_ModifyWeaponRotation") {
      if ListenerAction.IsButtonJustPressed(action) {
        this.m_tweakRotation = true;
      } else {
        if ListenerAction.IsButtonJustReleased(action) {
          this.m_tweakRotation = false;
        };
      };
    };
    if Equals(ListenerAction.GetName(action), n"Debug_ResetWeaponPosition") {
      if this.IsOwnerAiming() {
        this.ResetWeaponAimOffsetFromInput();
      } else {
        this.ResetWeaponOffsetFromInput();
      };
    };
    if Equals(ListenerAction.GetName(action), n"Debug_FineTuneWeaponPose") {
      if ListenerAction.IsButtonJustPressed(action) {
        this.m_fineTuneWeaponPose = true;
      } else {
        if ListenerAction.IsButtonJustReleased(action) {
          this.m_fineTuneWeaponPose = false;
        };
      };
    };
    if this.m_tweakPosition {
      if Equals(ListenerAction.GetName(action), n"DebugWeaponPosX") {
        if this.m_fineTuneWeaponPose {
          this.m_weaponPosDeltaX += ListenerAction.GetValue(action) * this.m_positionSensitivityFineTuning;
        } else {
          this.m_weaponPosDeltaX += ListenerAction.GetValue(action) * this.m_positionSensitivity;
        };
      };
      if Equals(ListenerAction.GetName(action), n"DebugWeaponPosY") {
        if this.m_fineTuneWeaponPose {
          this.m_weaponPosDeltaY -= ListenerAction.GetValue(action) * this.m_positionSensitivityFineTuning;
        } else {
          this.m_weaponPosDeltaY -= ListenerAction.GetValue(action) * this.m_positionSensitivity;
        };
      };
      if Equals(ListenerAction.GetName(action), n"DebugWeaponPosZ") {
        if this.m_fineTuneWeaponPose {
          this.m_weaponPosDeltaZ += ListenerAction.GetValue(action) * this.m_positionSensitivityFineTuning;
        } else {
          this.m_weaponPosDeltaZ += ListenerAction.GetValue(action) * this.m_positionSensitivity;
        };
      };
    };
    if this.m_tweakRotation {
      if Equals(ListenerAction.GetName(action), n"DebugWeaponRotX") {
        if this.m_fineTuneWeaponPose {
          this.m_weaponRotDeltaX -= ListenerAction.GetValue(action) * this.m_rotationSensitivityFineTuning;
        } else {
          this.m_weaponRotDeltaX -= ListenerAction.GetValue(action) * this.m_rotationSensitivity;
        };
        if this.m_tweakPosition && this.m_tweakRotation {
          this.m_weaponRotDeltaX *= -1.00;
        };
      };
      if Equals(ListenerAction.GetName(action), n"DebugWeaponRotY") {
        if this.m_fineTuneWeaponPose {
          this.m_weaponRotDeltaY += ListenerAction.GetValue(action) * this.m_rotationSensitivityFineTuning;
        } else {
          this.m_weaponRotDeltaY += ListenerAction.GetValue(action) * this.m_rotationSensitivity;
        };
      };
      if Equals(ListenerAction.GetName(action), n"DebugWeaponRotZ") {
        if this.m_fineTuneWeaponPose {
          this.m_weaponRotDeltaZ += ListenerAction.GetValue(action) * this.m_rotationSensitivityFineTuning;
        } else {
          this.m_weaponRotDeltaZ += ListenerAction.GetValue(action) * this.m_rotationSensitivity;
        };
        if this.m_tweakPosition && this.m_tweakRotation {
          this.m_weaponRotDeltaZ *= -1.00;
        };
      };
    };
    if Equals(ListenerAction.GetName(action), n"Debug_ToggleFocusMode") {
      this.m_visionSwitch = this.GetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.VisionDebug) == EnumInt(gamePSMVisionDebug.VisionToggle);
      if ListenerAction.IsButtonJustPressed(action) {
        if this.m_visionSwitch {
          this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.VisionDebug, EnumInt(gamePSMVisionDebug.Default));
        } else {
          if !this.m_visionSwitch {
            this.SetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.VisionDebug, EnumInt(gamePSMVisionDebug.VisionToggle));
          };
        };
      };
    };
  }

  private final func ResetDeltas() -> Void {
    this.m_weaponPosDeltaX = 0.00;
    this.m_weaponPosDeltaY = 0.00;
    this.m_weaponPosDeltaZ = 0.00;
    this.m_weaponRotDeltaX = 0.00;
    this.m_weaponRotDeltaY = 0.00;
    this.m_weaponRotDeltaZ = 0.00;
  }

  private final func ResetData() -> Void {
    this.m_weaponPosVec = new Vector4(0.00, 0.00, 0.00, 1.00);
    this.m_weaponRotVec = new Vector4(0.00, 0.00, 0.00, 1.00);
    this.m_weaponAimPosVec = new Vector4(0.00, 0.00, 0.00, 1.00);
    this.m_weaponAimRotVec = new Vector4(0.00, 0.00, 0.00, 1.00);
    this.ResetWeaponOffsetFromInput();
    this.ResetWeaponAimOffsetFromInput();
  }

  private final func ResetWeaponOffsetFromInput() -> Void {
    this.m_weaponPosOffsetFromInput = new Vector4(0.00, 0.00, 0.00, 1.00);
    this.m_weaponRotOffsetFromInput = new Vector4(0.00, 0.00, 0.00, 1.00);
  }

  private final func ResetWeaponAimOffsetFromInput() -> Void {
    this.m_weaponAimPosOffsetFromInput = new Vector4(0.00, 0.00, 0.00, 1.00);
    this.m_weaponAimRotOffsetFromInput = new Vector4(0.00, 0.00, 0.00, 1.00);
  }

  private final func ShouldDisplayDebugInfo() -> Bool {
    return NotEquals(this.m_weaponPosOffsetFromInput, new Vector4(0.00, 0.00, 0.00, 1.00)) || NotEquals(this.m_weaponRotOffsetFromInput, new Vector4(0.00, 0.00, 0.00, 1.00)) || NotEquals(this.m_weaponAimPosOffsetFromInput, new Vector4(0.00, 0.00, 0.00, 1.00)) || NotEquals(this.m_weaponAimRotOffsetFromInput, new Vector4(0.00, 0.00, 0.00, 1.00));
  }

  private final func UpdateTweakDBParams() -> Void {
    this.m_positionSensitivity = TweakDBInterface.GetFloat(t"weapons.weaponPoseTweak.positionSensitivity", 0.00);
    this.m_positionSensitivityFineTuning = TweakDBInterface.GetFloat(t"weapons.weaponPoseTweak.positionSensitivityFineTuning", 0.00);
    this.m_rotationSensitivity = TweakDBInterface.GetFloat(t"weapons.weaponPoseTweak.rotationSensitivity", 0.10);
    this.m_rotationSensitivityFineTuning = TweakDBInterface.GetFloat(t"weapons.weaponPoseTweak.rotationSensitivityFineTuning", 0.00);
  }

  private final func UpdateData() -> Void {
    if TweakDBInterface.GetBool(t"weapons.general.usePositionAndRotationFromTweakDB", false) {
      this.UpdateWeaponPositionDataFromTweakDB();
    } else {
      this.UpdateWeaponPositionDataFromWeaponStats();
    };
    this.UpdateCameraData();
  }

  private final func SendData() -> Void {
    this.SendWeaponPositionData();
    this.SendCameraData();
  }

  private final func UpdateWeaponPositionDataFromTweakDB() -> Void {
    this.m_weaponPosVec.X = TweakDBInterface.GetFloat(t"weapons.position.posX", 0.00);
    this.m_weaponPosVec.Y = TweakDBInterface.GetFloat(t"weapons.position.posY", 0.00);
    this.m_weaponPosVec.Z = TweakDBInterface.GetFloat(t"weapons.position.posZ", 0.00);
    this.m_weaponAimPosVec.X = TweakDBInterface.GetFloat(t"weapons.position.posAimX", 0.00);
    this.m_weaponAimPosVec.Y = TweakDBInterface.GetFloat(t"weapons.position.posAimY", 0.00);
    this.m_weaponAimPosVec.Z = TweakDBInterface.GetFloat(t"weapons.position.posAimZ", 0.00);
    this.m_weaponRotVec.X = TweakDBInterface.GetFloat(t"weapons.rotation.rotZ", 0.00);
    this.m_weaponRotVec.Y = TweakDBInterface.GetFloat(t"weapons.rotation.rotY", 0.00);
    this.m_weaponRotVec.Z = TweakDBInterface.GetFloat(t"weapons.rotation.rotX", 0.00);
    this.m_weaponAimRotVec.X = TweakDBInterface.GetFloat(t"weapons.rotation.rotAimX", 0.00);
    this.m_weaponAimRotVec.Y = TweakDBInterface.GetFloat(t"weapons.rotation.rotAimY", 0.00);
    this.m_weaponAimRotVec.Z = TweakDBInterface.GetFloat(t"weapons.rotation.rotAimZ", 0.00);
  }

  private final func UpdateWeaponPositionDataFromWeaponStats() -> Void {
    let statsSystem: ref<StatsSystem>;
    let weaponID: StatsObjectID;
    let weapon: ref<GameObject> = GameInstance.GetTransactionSystem(this.m_playerPuppet.GetGame()).GetItemInSlot(this.m_playerPuppet, t"AttachmentSlots.WeaponRight");
    if !IsDefined(weapon) {
      return;
    };
    weaponID = Cast(weapon.GetEntityID());
    statsSystem = GameInstance.GetStatsSystem(this.m_playerPuppet.GetGame());
    if !IsDefined(statsSystem) {
      return;
    };
    this.m_weaponPosVec.X = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponPosX);
    this.m_weaponPosVec.Y = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponPosY);
    this.m_weaponPosVec.Z = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponPosZ);
    this.m_weaponAimPosVec.X = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponPosAdsX);
    this.m_weaponAimPosVec.Y = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponPosAdsY);
    this.m_weaponAimPosVec.Z = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponPosAdsZ);
    this.m_weaponRotVec.X = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponRotX);
    this.m_weaponRotVec.Y = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponRotY);
    this.m_weaponRotVec.Z = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponRotZ);
    this.m_weaponAimRotVec.X = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponRotAdsX);
    this.m_weaponAimRotVec.Y = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponRotAdsY);
    this.m_weaponAimRotVec.Z = statsSystem.GetStatValue(weaponID, gamedataStatType.WeaponRotAdsZ);
  }

  private final func UpdateWeaponPositionDataFromInput() -> Void {
    if this.IsOwnerAiming() {
      this.m_weaponAimPosOffsetFromInput.X += this.m_weaponPosDeltaX;
      this.m_weaponAimPosOffsetFromInput.Y += this.m_weaponPosDeltaY;
      this.m_weaponAimPosOffsetFromInput.Z += this.m_weaponPosDeltaZ;
      this.m_weaponAimRotOffsetFromInput.X += this.m_weaponRotDeltaX;
      this.m_weaponAimRotOffsetFromInput.Y += this.m_weaponRotDeltaY;
      this.m_weaponAimRotOffsetFromInput.Z += this.m_weaponRotDeltaZ;
    } else {
      this.m_weaponPosOffsetFromInput.X += this.m_weaponPosDeltaX;
      this.m_weaponPosOffsetFromInput.Y += this.m_weaponPosDeltaY;
      this.m_weaponPosOffsetFromInput.Z += this.m_weaponPosDeltaZ;
      this.m_weaponRotOffsetFromInput.X += this.m_weaponRotDeltaX;
      this.m_weaponRotOffsetFromInput.Y += this.m_weaponRotDeltaY;
      this.m_weaponRotOffsetFromInput.Z += this.m_weaponRotDeltaZ;
    };
  }

  private final func SendWeaponPositionData() -> Void {
    AnimationControllerComponent.SetInputVector(this.GetOwner(), n"weapon_offset_shoulder", this.m_weaponPosVec);
    AnimationControllerComponent.SetInputVector(this.GetOwner(), n"weapon_offset_aiming", this.m_weaponAimPosVec);
    AnimationControllerComponent.SetInputVector(this.GetOwner(), n"weapon_rotation_shoulder", this.m_weaponRotVec);
    AnimationControllerComponent.SetInputVector(this.GetOwner(), n"weapon_rotation_aiming", this.m_weaponAimRotVec);
  }

  private final func UpdateCameraData() -> Void {
    this.m_cameraStandHeight = TweakDBInterface.GetFloat(t"player.camera.standHeight", -1.00);
    this.m_cameraCrouchHeight = TweakDBInterface.GetFloat(t"player.camera.crouchHeight", -1.00);
    this.m_cameraHeightOffset = TweakDBInterface.GetFloat(t"player.camera.cameraHeighOffset", 0.00);
    this.m_cameraResetPitch = TweakDBInterface.GetBool(t"player.camera.resetPitch", false);
  }

  private final func SendCameraData() -> Void {
    let tempVectorCauseStuffsRetarted: Vector4;
    Vector4.Zero(tempVectorCauseStuffsRetarted);
    tempVectorCauseStuffsRetarted.Z = this.m_cameraStandHeight;
    AnimationControllerComponent.SetInputVector(this.GetOwner(), n"debug_stand_camera_position", tempVectorCauseStuffsRetarted);
    tempVectorCauseStuffsRetarted.Z = this.m_cameraCrouchHeight;
    AnimationControllerComponent.SetInputVector(this.GetOwner(), n"debug_crouch_camera_position", tempVectorCauseStuffsRetarted);
    AnimationControllerComponent.SetInputBool(this.GetOwner(), n"debug_camera_reset_pitch", this.m_cameraResetPitch);
    AnimationControllerComponent.SetInputFloat(this.GetOwner(), n"debug_camera_height_offset", this.m_cameraHeightOffset);
  }

  private final func IsOwnerAiming() -> Bool {
    return this.GetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
  }

  private final func UpdateDebugInfo() -> Void {
    this.UILayerID0 = GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).DrawText(new Vector4(20.00, 550.00, 0.00, 0.00), "Shoulder Position Offset: " + VectorToString(this.m_weaponPosVec), gameDebugViewETextAlignment.Left, new Color(0u, 255u, 0u, 255u));
    GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).SetScale(this.UILayerID0, new Vector4(1.00, 1.00, 0.00, 0.00));
    this.UILayerID1 = GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).DrawText(new Vector4(20.00, 570.00, 0.00, 0.00), "Shoulder Rotation Offset: " + VectorToString(this.m_weaponRotVec), gameDebugViewETextAlignment.Left, new Color(0u, 255u, 0u, 255u));
    GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).SetScale(this.UILayerID1, new Vector4(1.00, 1.00, 0.00, 0.00));
    this.UILayerID2 = GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).DrawText(new Vector4(20.00, 590.00, 0.00, 0.00), "Ironsight Position Offset: " + VectorToString(this.m_weaponAimPosVec), gameDebugViewETextAlignment.Left, new Color(0u, 255u, 0u, 255u));
    GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).SetScale(this.UILayerID2, new Vector4(1.00, 1.00, 0.00, 0.00));
    this.UILayerID3 = GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).DrawText(new Vector4(20.00, 610.00, 0.00, 0.00), "Ironsight Rotation Offset: " + VectorToString(this.m_weaponAimRotVec), gameDebugViewETextAlignment.Left, new Color(0u, 255u, 0u, 255u));
    GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).SetScale(this.UILayerID3, new Vector4(1.00, 1.00, 0.00, 0.00));
  }

  private final func ClearDebugInfo() -> Void {
    GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).ClearLayer(this.UILayerID0);
    GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).ClearLayer(this.UILayerID1);
    GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).ClearLayer(this.UILayerID2);
    GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame()).ClearLayer(this.UILayerID3);
  }
}
