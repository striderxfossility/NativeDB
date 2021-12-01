
public final native class AudioSystem extends gameIGameAudioSystem {

  @default(AudioSystem, 0)
  private let m_enemyPingStimCount: Uint8;

  @default(AudioSystem, false)
  private let m_mixHasDetectedCombat: Bool;

  public final native func Play(eventName: CName, opt entityID: EntityID, opt emitterName: CName) -> Void;

  public final native func Stop(eventName: CName, opt entityID: EntityID, opt emitterName: CName) -> Void;

  public final native func Switch(switchName: CName, switchValue: CName, opt entityID: EntityID, opt emitterName: CName) -> Void;

  public final native func Parameter(parameterName: CName, parameterValue: Float, opt entityID: EntityID, opt emitterName: CName) -> Void;

  public final native func PlayImpact(impactContext: CName, position: Vector4, object: ref<GameObject>) -> Void;

  public final native func State(stateGroup: String, state: String) -> Void;

  public final native func GlobalParameter(parameterName: CName, parameterValue: Float) -> Void;

  public final native func LoadBank(bankName: String) -> Void;

  public final native func UnloadBank(bankName: String) -> Void;

  public final native func PlayShockwave(shockwaveType: CName, position: Vector4) -> Void;

  public final native func OpenAcousticPortal(object: ref<GameObject>) -> Void;

  public final native func CloseAcousticPortal(object: ref<GameObject>) -> Void;

  public final native func NotifyGameTone(eventName: CName) -> Void;

  public final native func RequestSongOnRadioStation(stationName: CName, songName: CName) -> Void;

  public final native func RequestSongOnPlaylist(playlistName: CName, songName: CName) -> Void;

  public final native func GetPlaylistSongs(playlistName: CName) -> array<CName>;

  public final native func GetPlaylistCurrentSong(playlistName: CName) -> CName;

  public final native func SetInScanningMode(inScanningMode: Bool) -> Void;

  public final native func IsInScanningMode() -> Bool;

  public final native func RegisterEnemyPingStim(enemyState: gamedataNPCHighLevelState, isPoliceman: Bool) -> Void;

  public final native func RegisterPreventionHeatStage(preventionHeatStage: Uint8) -> Void;

  public final native func SetBDCameraListenerOverride(value: Bool) -> Void;

  public final native func VoIsPerceptible(entityId: EntityID) -> Bool;

  public final native func TriggerFlyby(position: Vector4, direction: Vector4, startPosition: Vector4, object: ref<GameObject>) -> Void;

  public final func PlayLootAllSound() -> Void {
    this.Play(n"ui_loot_take_all");
  }

  public final func PlayItemActionSound(action: CName, itemData: wref<gameItemData>) -> Void {
    if Equals(action, n"Loot") {
      this.PlayItemLootedSound(itemData);
    } else {
      if Equals(action, n"Eat") {
        this.Play(n"ui_loot_eat");
      } else {
        if Equals(action, n"Drink") {
          this.Play(n"ui_loot_drink");
        } else {
          if Equals(action, n"Consume") {
            this.Play(n"ui_menu_item_consumable_generic");
          };
        };
      };
    };
  }

  private final func PlayItemLootedSound(itemData: wref<gameItemData>) -> Void {
    let eventName: CName;
    let itemQuality: gamedataQuality = RPGManager.GetItemDataQuality(itemData);
    let itemCategory: gamedataItemCategory = RPGManager.GetItemCategory(itemData.GetID());
    let itemType: gamedataItemType = itemData.GetItemType();
    if Equals(itemType, gamedataItemType.Invalid) && Equals(itemCategory, gamedataItemCategory.Invalid) && Equals(itemQuality, gamedataQuality.Invalid) {
      return;
    };
    if Equals(itemType, gamedataItemType.Con_Ammo) {
      eventName = n"ui_loot_ammo";
    } else {
      if Equals(itemType, gamedataItemType.Gen_Readable) || Equals(itemType, gamedataItemType.Con_Inhaler) || Equals(itemType, gamedataItemType.Con_Injector) {
        eventName = n"ui_loot_additional";
      } else {
        if Equals(itemCategory, gamedataItemCategory.Cyberware) || Equals(itemCategory, gamedataItemCategory.Part) && (Equals(itemType, gamedataItemType.Prt_Fragment) || Equals(itemType, gamedataItemType.Prt_Mod)) {
          eventName = n"ui_loot_cyberware";
        } else {
          if Equals(itemCategory, gamedataItemCategory.Weapon) {
            if Equals(itemType, gamedataItemType.Wea_Melee) || Equals(itemType, gamedataItemType.Wea_Hammer) || Equals(itemType, gamedataItemType.Wea_Katana) || Equals(itemType, gamedataItemType.Wea_Knife) || Equals(itemType, gamedataItemType.Wea_LongBlade) || Equals(itemType, gamedataItemType.Wea_OneHandedClub) || Equals(itemType, gamedataItemType.Wea_TwoHandedClub) {
              eventName = n"ui_loot_melee";
            } else {
              eventName = n"ui_loot_gun";
            };
          } else {
            if Equals(itemCategory, gamedataItemCategory.Clothing) {
              if Equals(itemType, gamedataItemType.Clo_Head) || Equals(itemType, gamedataItemType.Clo_Face) {
                eventName = n"ui_loot_head";
              } else {
                if Equals(itemType, gamedataItemType.Clo_Legs) || Equals(itemType, gamedataItemType.Clo_Feet) {
                  eventName = n"ui_loot_lower_body";
                } else {
                  if Equals(itemType, gamedataItemType.Clo_Outfit) || Equals(itemType, gamedataItemType.Clo_OuterChest) || Equals(itemType, gamedataItemType.Clo_InnerChest) {
                    eventName = n"ui_loot_upper_body";
                  };
                };
              };
            } else {
              if itemData.HasTag(n"Currency") {
                eventName = n"ui_loot_cash_picking";
              } else {
                eventName = n"ui_loot_generic";
              };
            };
          };
        };
      };
    };
    this.Play(eventName);
    if Equals(itemQuality, gamedataQuality.Legendary) || Equals(itemQuality, gamedataQuality.Iconic) {
      this.Play(n"ui_loot_rarity_legendary");
    } else {
      if Equals(itemQuality, gamedataQuality.Epic) {
        this.Play(n"ui_loot_rarity_epic");
      };
    };
  }

  public final func HandleDynamicMixAreaEnter(localPlayer: ref<GameObject>) -> Void {
    this.m_enemyPingStimCount += 1u;
    if this.m_enemyPingStimCount == 1u {
      localPlayer.GetStimBroadcasterComponent().AddActiveStimuli(localPlayer, gamedataStimType.AudioEnemyPing, -1.00);
    };
  }

  public final func HandleDynamicMixAreaExit(localPlayer: ref<GameObject>) -> Void {
    if this.m_enemyPingStimCount > 0u {
      this.m_enemyPingStimCount -= 1u;
      if this.m_enemyPingStimCount == 0u {
        localPlayer.GetStimBroadcasterComponent().RemoveActiveStimuliByName(localPlayer, gamedataStimType.AudioEnemyPing);
      };
    };
  }

  public final func HandleCombatMix(localPlayer: ref<GameObject>) -> Void {
    this.m_mixHasDetectedCombat = true;
  }

  public final func HandleOutOfCombatMix(localPlayer: ref<GameObject>) -> Void {
    if this.m_mixHasDetectedCombat {
      if this.m_enemyPingStimCount > 0u {
        localPlayer.GetStimBroadcasterComponent().AddActiveStimuli(localPlayer, gamedataStimType.AudioEnemyPing, -1.00);
      };
      this.m_mixHasDetectedCombat = false;
    };
  }

  protected final cb func OnGameEnd() -> Bool {
    this.m_enemyPingStimCount = 0u;
    this.m_mixHasDetectedCombat = false;
  }
}

public native class worldScriptedAudioSignpostTrigger extends IScriptable {

  protected cb func OnPlayerEnter(localPlayer: ref<GameObject>) -> Bool {
    GameInstance.GetAudioSystem(localPlayer.GetGame()).HandleDynamicMixAreaEnter(localPlayer);
  }

  protected cb func OnPlayerExit(localPlayer: ref<GameObject>) -> Bool {
    GameInstance.GetAudioSystem(localPlayer.GetGame()).HandleDynamicMixAreaExit(localPlayer);
  }
}
