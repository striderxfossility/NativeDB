
public class buffListGameController extends inkHUDGameController {

  private edit let m_buffsList: inkHorizontalPanelRef;

  private let m_bbBuffList: ref<CallbackHandle>;

  private let m_bbDeBuffList: ref<CallbackHandle>;

  private let m_uiBlackboard: wref<IBlackboard>;

  private let m_buffDataList: array<BuffInfo>;

  private let m_debuffDataList: array<BuffInfo>;

  private let m_buffWidgets: array<wref<inkWidget>>;

  private let m_UISystem: wref<UISystem>;

  private let m_pendingRequests: Int32;

  protected cb func OnInitialize() -> Bool {
    this.m_uiBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
    if IsDefined(this.m_uiBlackboard) {
      this.m_bbBuffList = this.m_uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.BuffsList, this, n"OnBuffDataChanged");
      this.m_bbDeBuffList = this.m_uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.DebuffsList, this, n"OnDeBuffDataChanged");
      this.m_uiBlackboard.SignalVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.BuffsList);
      this.m_uiBlackboard.SignalVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.DebuffsList);
    };
    inkWidgetRef.SetVisible(this.m_buffsList, false);
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_uiBlackboard) {
      this.m_uiBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.BuffsList, this.m_bbBuffList);
      this.m_uiBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.DebuffsList, this.m_bbDeBuffList);
    };
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    this.m_UISystem = GameInstance.GetUISystem(playerGameObject.GetGame());
  }

  protected cb func OnBuffDataChanged(value: Variant) -> Bool {
    this.m_buffDataList = FromVariant(value);
    this.UpdateBuffs();
  }

  protected cb func OnDeBuffDataChanged(value: Variant) -> Bool {
    this.m_debuffDataList = FromVariant(value);
    this.UpdateBuffs();
  }

  private final func UpdateBuffs() -> Void {
    let i: Int32;
    let requestsToSpawn: Int32;
    let incomingBuffsCount: Int32 = ArraySize(this.m_debuffDataList) + ArraySize(this.m_buffDataList);
    let currentBuffsAndRequests: Int32 = inkCompoundRef.GetNumChildren(this.m_buffsList) + this.m_pendingRequests;
    if currentBuffsAndRequests < incomingBuffsCount {
      this.m_pendingRequests = incomingBuffsCount - currentBuffsAndRequests;
      requestsToSpawn = this.m_pendingRequests;
      i = 0;
      while i < requestsToSpawn {
        this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_buffsList), n"Buff", this, n"OnBuffSpawned");
        i = i + 1;
      };
    };
    if this.m_pendingRequests <= 0 {
      this.UpdateBuffDebuffList();
      this.UpdateVisibility();
    };
  }

  protected cb func OnBuffSpawned(newItem: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    newItem.SetVisible(false);
    ArrayPush(this.m_buffWidgets, newItem);
    this.m_pendingRequests -= 1;
    if this.m_pendingRequests <= 0 {
      this.UpdateBuffDebuffList();
      this.UpdateVisibility();
    };
  }

  private final func UpdateVisibility() -> Void {
    this.GetRootWidget().SetVisible(false);
    this.GetRootWidget().SetVisible(true);
    this.GetRootWidget().SetVisible(inkWidgetRef.IsVisible(this.m_buffsList));
  }

  private final func UpdateBuffDebuffList() -> Void {
    let buffList: array<BuffInfo>;
    let buffTimeRemaining: Float;
    let currBuffLoc: wref<buffListItemLogicController>;
    let currBuffWidget: wref<inkWidget>;
    let data: ref<StatusEffect_Record>;
    let incomingBuffsCount: Int32;
    let onScreenBuffsCount: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_buffDataList) {
      ArrayPush(buffList, this.m_buffDataList[i]);
      i = i + 1;
    };
    i = 0;
    while i < ArraySize(this.m_debuffDataList) {
      ArrayPush(buffList, this.m_debuffDataList[i]);
      i = i + 1;
    };
    incomingBuffsCount = ArraySize(buffList);
    onScreenBuffsCount = inkCompoundRef.GetNumChildren(this.m_buffsList);
    this.SendVisibilityUpdate(inkWidgetRef.IsVisible(this.m_buffsList), incomingBuffsCount > 0);
    inkWidgetRef.SetVisible(this.m_buffsList, incomingBuffsCount > 0);
    if incomingBuffsCount != 0 {
      if onScreenBuffsCount > incomingBuffsCount {
        i = incomingBuffsCount - 1;
        while i < onScreenBuffsCount {
          currBuffWidget = this.m_buffWidgets[i];
          currBuffWidget.SetVisible(false);
          i = i + 1;
        };
      };
    };
    i = 0;
    while i < incomingBuffsCount {
      data = TweakDBInterface.GetStatusEffectRecord(buffList[i].buffID);
      buffTimeRemaining = buffList[i].timeRemaining;
      if !IsDefined(data) || !IsDefined(data.UiData()) || Equals(data.UiData().IconPath(), "") {
      } else {
        currBuffWidget = this.m_buffWidgets[i];
        currBuffWidget.SetVisible(true);
        currBuffLoc = currBuffWidget.GetController() as buffListItemLogicController;
        currBuffLoc.SetData(StringToName(data.UiData().IconPath()), buffTimeRemaining);
      };
      i = i + 1;
    };
  }

  private final func SendVisibilityUpdate(oldVisible: Bool, nowVisible: Bool) -> Void {
    let evt: ref<BuffListVisibilityChangedEvent>;
    if NotEquals(oldVisible, nowVisible) {
      evt = new BuffListVisibilityChangedEvent();
      evt.m_hasBuffs = nowVisible;
      this.m_UISystem.QueueEvent(evt);
    };
  }
}

public class buffListItemLogicController extends inkLogicController {

  private edit let m_icon: inkImageRef;

  private edit let m_label: inkTextRef;

  protected cb func OnInitialize() -> Bool;

  public final func SetData(icon: CName, time: Float) -> Void {
    this.SetTimeText(time);
    InkImageUtils.RequestSetImage(this, this.m_icon, "UIIcon." + NameToString(icon));
  }

  private final func SetTimeText(f: Float) -> Void {
    let textParams: ref<inkTextParams> = new inkTextParams();
    let time: GameTime = GameTime.MakeGameTime(0, 0, 0, Cast(f));
    let minutes: Int32 = GameTime.Minutes(time);
    let seconds: Int32 = GameTime.Seconds(time);
    if f >= 0.00 {
      if minutes > 0 {
        inkTextRef.SetText(this.m_label, "{TIME,time,mm:ss}");
        textParams.AddTime("TIME", time);
        inkTextRef.SetTextParameters(this.m_label, textParams);
      } else {
        inkTextRef.SetText(this.m_label, ToString(seconds));
      };
    } else {
      inkTextRef.SetText(this.m_label, "");
    };
  }

  public final func SetData(icon: TweakDBID, time: Float) -> Void {
    this.SetTimeText(time);
    InkImageUtils.RequestSetImage(this, this.m_icon, icon);
  }

  public final func SetData(icon: CName, stackCount: Int32) -> Void {
    if stackCount > 1 {
      inkTextRef.SetText(this.m_label, "x" + ToString(stackCount));
    } else {
      inkTextRef.SetText(this.m_label, "");
    };
    InkImageUtils.RequestSetImage(this, this.m_icon, "UIIcon." + NameToString(icon));
  }
}
