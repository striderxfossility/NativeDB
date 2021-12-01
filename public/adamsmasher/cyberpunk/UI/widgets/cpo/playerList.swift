
public native class gameuiPlayerListGameController extends inkHUDGameController {

  private let m_playerEntries: array<PlayerListEntryData>;

  private edit let m_container: inkCompoundRef;

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.AddPlayerToList(playerPuppet);
  }

  protected cb func OnRemotePlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.AddPlayerToList(playerPuppet);
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.RemovePlayerFromList(playerPuppet);
  }

  protected cb func OnRemotePlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.RemovePlayerFromList(playerPuppet);
  }

  private final func AddPlayerToList(playerPuppet: ref<GameObject>) -> Void {
    let playerListEntryData: PlayerListEntryData;
    let playerListEntry: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_container), n"player_list_entry");
    let controller: wref<PlayerListEntryLogicController> = playerListEntry.GetController() as PlayerListEntryLogicController;
    controller.SetEntryData(playerPuppet);
    controller.SetEntryColorAndIcon(playerPuppet);
    playerListEntryData.playerObject = playerPuppet;
    playerListEntryData.playerListEntry = playerListEntry;
    ArrayPush(this.m_playerEntries, playerListEntryData);
  }

  private final func RemovePlayerFromList(playerPuppet: ref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_playerEntries) {
      if this.m_playerEntries[i].playerObject == playerPuppet {
        inkCompoundRef.RemoveChild(this.m_container, this.m_playerEntries[i].playerListEntry);
        ArrayErase(this.m_playerEntries, i);
      } else {
        i += 1;
      };
    };
  }
}

public class PlayerListEntryLogicController extends inkLogicController {

  private edit let m_playerNameLabel: inkWidgetRef;

  private edit let m_playerClassIcon: inkImageRef;

  private final func GetPlayerClassName(playerPuppet: ref<GameObject>) -> CName {
    let characterRecordID: TweakDBID = (playerPuppet as gamePuppetBase).GetRecordID();
    let className: CName = TweakDBInterface.GetCharacterRecord(characterRecordID).CpoClassName();
    return className;
  }

  public final func SetEntryData(playerPuppet: ref<GameObject>) -> Void {
    let playerNickname: String;
    let textLabel: wref<inkText>;
    let mpPlayerMgr: ref<mpPlayerManager> = GameInstance.GetPlayerManagerSystem(playerPuppet.GetGame()) as mpPlayerManager;
    if IsDefined(mpPlayerMgr) {
      playerNickname = mpPlayerMgr.GetPlayerNicknameByGameObject(playerPuppet);
    } else {
      playerNickname = "Local";
    };
    textLabel = inkWidgetRef.Get(this.m_playerNameLabel) as inkText;
    textLabel.SetText(playerNickname);
  }

  public final func SetEntryColorAndIcon(playerPuppet: ref<GameObject>) -> Void {
    let classIcon: wref<inkImage>;
    let className: CName = this.GetPlayerClassName(playerPuppet);
    let textLabel: wref<inkText> = inkWidgetRef.Get(this.m_playerNameLabel) as inkText;
    textLabel.SetState(className);
    classIcon = inkWidgetRef.Get(this.m_playerClassIcon) as inkImage;
    classIcon.SetState(className);
    classIcon.SetTexturePart(className);
  }
}
