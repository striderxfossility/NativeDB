
public class UnlockMinigameProgramEffector extends Effector {

  public let m_minigameProgram: MinigameProgramData;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let actionID: TweakDBID = TDBID.Create(TweakDBInterface.GetString(record + t".networkAction", ""));
    this.m_minigameProgram.actionID = actionID;
    this.m_minigameProgram.programName = StringToName(LocKeyToString(TweakDBInterface.GetObjectActionRecord(actionID).ObjectActionUI().Caption()));
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let player: ref<PlayerPuppet> = owner as PlayerPuppet;
    if IsDefined(player) {
      this.StoreMinigameProgramsOnPlayer(this.m_minigameProgram, player, true);
    };
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(game);
    if IsDefined(player) {
      this.StoreMinigameProgramsOnPlayer(this.m_minigameProgram, player, false);
    };
  }

  private final func StoreMinigameProgramsOnPlayer(program: MinigameProgramData, player: ref<PlayerPuppet>, addOrRemove: Bool) -> Void {
    let evt: ref<UpdateMiniGameProgramsEvent> = new UpdateMiniGameProgramsEvent();
    evt.program = program;
    evt.add = addOrRemove;
    player.QueueEvent(evt);
  }
}
