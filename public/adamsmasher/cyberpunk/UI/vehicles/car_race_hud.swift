
public class hudCarRaceController extends inkHUDGameController {

  private edit let m_Countdown: inkCanvasRef;

  private edit let m_PositionCounter: inkCanvasRef;

  private edit let m_RacePosition: inkTextRef;

  private edit let m_RaceTime: inkTextRef;

  private edit let m_RaceCheckpoint: inkTextRef;

  private let m_maxPosition: Int32;

  private let m_maxCheckpoint: Int32;

  private let m_playerPosition: Int32;

  private let m_minute: Int32;

  private let m_activeVehicleUIBlackboard: wref<IBlackboard>;

  private let m_activeVehicle: wref<VehicleObject>;

  private let m_raceStartEngineTime: EngineTime;

  private let m_factCallbackID: Uint32;

  protected cb func OnInitialize() -> Bool;

  protected cb func OnUninitialize() -> Bool {
    this.Setup(false);
  }

  protected cb func OnForwardVehicleRaceUIEvent(evt: ref<ForwardVehicleRaceUIEvent>) -> Bool {
    switch evt.mode {
      case vehicleRaceUI.PreRaceSetup:
        this.GetRootWidget().SetVisible(false);
        inkWidgetRef.SetVisible(this.m_Countdown, false);
        inkWidgetRef.SetVisible(this.m_PositionCounter, false);
        this.m_maxPosition = evt.maxPosition;
        this.m_maxCheckpoint = evt.maxCheckpoints;
        this.Setup(true);
        break;
      case vehicleRaceUI.CountdownStart:
        this.StartCountdown();
        break;
      case vehicleRaceUI.RaceStart:
        this.StartRace();
        break;
      case vehicleRaceUI.RaceEnd:
        this.EndRace();
        break;
      case vehicleRaceUI.Disable:
        this.GetRootWidget().SetVisible(false);
        this.Setup(false);
    };
  }

  private final func Setup(on: Bool) -> Void {
    let questSys: ref<QuestsSystem>;
    this.m_activeVehicle = GetMountedVehicle(this.GetPlayerControlledObject());
    if this.m_activeVehicle == null {
      return;
    };
    this.m_activeVehicleUIBlackboard = GameInstance.GetBlackboardSystem(this.m_activeVehicle.GetGame()).Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
    questSys = GameInstance.GetQuestsSystem(this.m_activeVehicle.GetGame());
    if IsDefined(this.m_activeVehicleUIBlackboard) {
      if on {
        this.m_factCallbackID = questSys.RegisterEntity(n"sq024_current_race_checkpoint_fact_add", this.m_activeVehicle.GetEntityID());
      } else {
        questSys.UnregisterEntity(n"sq024_current_race_checkpoint_fact_add", this.m_factCallbackID);
        this.m_factCallbackID = 0u;
      };
    };
  }

  private final func StartCountdown() -> Void {
    this.PlayLibraryAnimation(n"Countdown");
    this.PlayLibraryAnimation(n"Position_counter");
    this.SetupCounters();
    inkWidgetRef.SetVisible(this.m_Countdown, true);
    inkWidgetRef.SetVisible(this.m_PositionCounter, true);
    this.GetRootWidget().SetVisible(true);
  }

  private final func SetupCounters() -> Void {
    let playerPosition: Int32;
    inkTextRef.SetText(this.m_RaceCheckpoint, "0/" + IntToString(this.m_maxCheckpoint));
    playerPosition = this.m_activeVehicleUIBlackboard.GetInt(GetAllBlackboardDefs().UI_ActiveVehicleData.PositionInRace);
    inkTextRef.SetText(this.m_RacePosition, IntToString(playerPosition) + "/" + IntToString(this.m_maxPosition));
    inkTextRef.SetText(this.m_RaceTime, "00:00:00");
  }

  private final func StartRace() -> Void {
    this.m_raceStartEngineTime = GameInstance.GetSimTime(this.m_activeVehicle.GetGame());
  }

  private final func EndRace() -> Void;

  protected cb func OnVehicleForwardRaceCheckpointFactEvent(evt: ref<VehicleForwardRaceCheckpointFactEvent>) -> Bool {
    let questSys: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_activeVehicle.GetGame());
    let factValue: Int32 = questSys.GetFact(n"sq024_current_race_checkpoint_fact_add");
    inkTextRef.SetText(this.m_RaceCheckpoint, IntToString(factValue) + "/" + IntToString(this.m_maxCheckpoint));
  }

  protected cb func OnVehicleForwardRaceClockUpdateEvent(evt: ref<VehicleForwardRaceClockUpdateEvent>) -> Bool {
    let currentPlayerPosition: Int32;
    let questSystem: ref<QuestsSystem>;
    let currentEngineTime: EngineTime = GameInstance.GetSimTime(this.m_activeVehicle.GetGame());
    let enginetimeToDisplay: EngineTime = currentEngineTime - this.m_raceStartEngineTime;
    let engineTimeFloat: Float = EngineTime.ToFloat(enginetimeToDisplay);
    let minutes: Int32 = RoundF(engineTimeFloat / 60.00);
    let second: Int32 = Cast(engineTimeFloat) - minutes * 60;
    let millisecondFloat: Float = engineTimeFloat - Cast(second) - Cast(minutes) * 60.00;
    let millisecond: Int32 = Cast(millisecondFloat * 100.00);
    let params: ref<inkTextParams> = new inkTextParams();
    params.AddNumber("Minutes", minutes);
    params.AddNumber("Seconds", second);
    params.AddNumber("Milliseconds", millisecond);
    inkTextRef.SetLocalizedTextScript(this.m_RaceTime, "LocKey#77071", params);
    currentPlayerPosition = this.m_activeVehicleUIBlackboard.GetInt(GetAllBlackboardDefs().UI_ActiveVehicleData.PositionInRace);
    if this.m_playerPosition != currentPlayerPosition {
      questSystem = GameInstance.GetQuestsSystem(this.m_activeVehicle.GetGame());
      this.m_playerPosition = currentPlayerPosition;
      inkTextRef.SetText(this.m_RacePosition, IntToString(this.m_playerPosition) + "/" + IntToString(this.m_maxPosition));
      questSystem.SetFact(n"sq024_current_race_player_position", this.m_playerPosition);
    };
  }
}
