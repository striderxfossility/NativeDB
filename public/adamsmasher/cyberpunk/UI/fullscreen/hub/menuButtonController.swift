
public class MenuItemController extends inkLogicController {

  public let m_menuData: MenuData;

  private edit let m_label: inkTextRef;

  private edit let m_icon: inkImageRef;

  private edit let m_frameHovered: inkWidgetRef;

  private edit let m_hoverPanel: inkWidgetRef;

  private edit let m_background: inkWidgetRef;

  private edit let m_levelFlag: inkWidgetRef;

  private edit let m_attrFlag: inkWidgetRef;

  private edit let m_attrText: inkTextRef;

  private edit let m_perkFlag: inkWidgetRef;

  private edit let m_perkText: inkTextRef;

  private let m_itemHovered: Bool;

  private let m_panelHovered: Bool;

  private let m_panelTransitionProxy: ref<inkAnimProxy>;

  private let m_buttonTransitionProxy: ref<inkAnimProxy>;

  private let m_isPanelShown: Bool;

  private let m_isDimmed: Bool;

  private let m_isHyperlink: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnRelease", this, n"OnMenuChangeRelease");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnItemHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnItemHoverOut");
    inkWidgetRef.SetOpacity(this.m_frameHovered, 0.00);
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnRelease", this, n"OnMenuChangeRelease");
    this.UnregisterFromCallback(n"OnHoverOver", this, n"OnItemHoverOver");
    this.UnregisterFromCallback(n"OnHoverOut", this, n"OnItemHoverOut");
    if inkWidgetRef.IsValid(this.m_hoverPanel) {
      this.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverPanelOver");
      this.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverPanelOut");
    };
  }

  public final func Init(menuData: MenuData) -> Void {
    this.m_menuData = menuData;
    inkTextRef.SetText(this.m_label, menuData.label);
    inkWidgetRef.SetVisible(this.m_attrFlag, menuData.attrFlag);
    inkTextRef.SetText(this.m_attrText, IntToString(menuData.attrText));
    inkWidgetRef.SetVisible(this.m_perkFlag, menuData.perkFlag);
    inkTextRef.SetText(this.m_perkText, IntToString(menuData.perkText));
    inkWidgetRef.SetVisible(this.m_levelFlag, menuData.attrFlag || menuData.perkFlag);
    if NotEquals(menuData.icon, n"") {
      inkWidgetRef.SetVisible(this.m_icon, true);
      inkImageRef.SetTexturePart(this.m_icon, menuData.icon);
    } else {
      inkWidgetRef.SetVisible(this.m_icon, false);
    };
    if this.m_menuData.disabled {
      this.GetRootWidget().SetOpacity(0.30);
      inkWidgetRef.SetOpacity(this.m_icon, 0.10);
      inkWidgetRef.SetOpacity(this.m_label, 0.10);
    };
  }

  public final func SetHyperlink(value: Bool) -> Void {
    this.m_isHyperlink = value;
  }

  public final func IsHyperlink() -> Bool {
    return this.m_isHyperlink;
  }

  public final func SetHoverPanel(hoverPanel: inkWidgetRef) -> Void {
    this.m_hoverPanel = hoverPanel;
    if inkWidgetRef.IsValid(this.m_hoverPanel) {
      inkWidgetRef.SetVisible(this.m_hoverPanel, false);
      inkWidgetRef.RegisterToCallback(this.m_hoverPanel, n"OnEnter", this, n"OnHoverPanelOver");
      inkWidgetRef.RegisterToCallback(this.m_hoverPanel, n"OnLeave", this, n"OnHoverPanelOut");
    };
  }

  protected cb func OnMenuChangeRelease(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<SelectMenuRequest>;
    let menuNotification: ref<UIMenuNotificationEvent>;
    if e.IsAction(n"click") {
      if !this.m_menuData.disabled {
        this.PlaySound(n"Button", n"OnPress");
        evt = new SelectMenuRequest();
        evt.m_eventData = this;
        this.QueueEvent(evt);
      } else {
        menuNotification = new UIMenuNotificationEvent();
        menuNotification.m_notificationType = UIMenuNotificationType.InventoryActionBlocked;
        this.QueueEvent(menuNotification);
      };
    };
  }

  protected cb func OnHoverPanelOver(evt: ref<inkPointerEvent>) -> Bool {
    this.m_panelHovered = true;
    this.UpdateState();
    this.UpdateDim(true);
  }

  protected cb func OnHoverPanelOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_panelHovered = false;
    this.UpdateState();
    this.UpdateDim(false);
  }

  protected cb func OnItemHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    if !this.m_menuData.disabled {
      inkWidgetRef.SetOpacity(this.m_frameHovered, 1.00);
      this.m_itemHovered = true;
      this.UpdateState();
    };
  }

  protected cb func OnItemHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    if !this.m_menuData.disabled {
      inkWidgetRef.SetOpacity(this.m_frameHovered, 0.00);
      this.m_itemHovered = false;
      this.UpdateState();
    };
  }

  private final func UpdateState() -> Void {
    let evtDelay: ref<MenuItemDelayedUpdate> = new MenuItemDelayedUpdate();
    this.QueueEvent(evtDelay);
  }

  private final func UpdateDim(value: Bool) -> Void {
    let evtDim: ref<MenuItemDimRequest> = new MenuItemDimRequest();
    evtDim.m_dim = value;
    this.QueueEvent(evtDim);
  }

  protected cb func OnMenuItemDimRequest(evt: ref<MenuItemDimRequest>) -> Bool {
    let buttonDimmed: Bool = !this.m_panelHovered && !this.m_itemHovered && this.m_menuData.parentIdentifier == -1 && evt.m_dim;
    if NotEquals(this.m_isDimmed, buttonDimmed) {
      this.m_isDimmed = buttonDimmed;
      if this.m_buttonTransitionProxy != null {
        this.m_buttonTransitionProxy.Stop(true);
        this.m_buttonTransitionProxy = null;
      };
      if this.m_isDimmed {
        this.m_buttonTransitionProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(n"button_dim", this.GetRootWidget());
      } else {
        this.m_buttonTransitionProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(n"button_default", this.GetRootWidget());
      };
    };
  }

  protected cb func OnMenuItemDelayedUpdate(evt: ref<MenuItemDelayedUpdate>) -> Bool {
    let panelVisibility: Bool;
    if inkWidgetRef.IsValid(this.m_hoverPanel) {
      panelVisibility = this.m_itemHovered || this.m_panelHovered;
      if NotEquals(panelVisibility, this.m_isPanelShown) {
        this.m_isPanelShown = panelVisibility;
        if this.m_panelTransitionProxy != null {
          this.m_panelTransitionProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnOutroFinished");
          this.m_panelTransitionProxy.Stop(true);
          this.m_panelTransitionProxy = null;
        };
        if this.m_isPanelShown {
          inkWidgetRef.SetVisible(this.m_hoverPanel, true);
          this.m_panelTransitionProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(n"buttons_panel_show", inkWidgetRef.Get(this.m_hoverPanel));
        } else {
          this.m_panelTransitionProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(n"buttons_panel_hide", inkWidgetRef.Get(this.m_hoverPanel));
          this.m_panelTransitionProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroFinished");
        };
      };
    };
  }

  protected cb func OnOutroFinished(anim: ref<inkAnimProxy>) -> Bool {
    inkWidgetRef.SetVisible(this.m_hoverPanel, false);
  }
}
