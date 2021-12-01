
public class PreGameSubMenuGameController extends inkGameController {

  protected let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  protected cb func OnInitialize() -> Bool {
    let buttonsList: wref<inkVerticalPanel>;
    let dpadLogic: wref<fullscreenDpadSupported>;
    let firstButton: wref<inkWidget>;
    let menuName: wref<inkText>;
    if IsDefined(this.SpawnFromExternal(this.GetRootWidget(), r"base\\gameplay\\gui\\fullscreen\\main_menu\\shared_data.inkwidget", n"MainColumn")) {
      menuName = this.GetWidget(n"MainColumn\\Container\\MenuName") as inkText;
      if IsDefined(menuName) {
        this.InitializeMenuName(menuName);
      };
      buttonsList = this.GetWidget(n"MainColumn\\Container\\ButtonsList") as inkVerticalPanel;
      if IsDefined(buttonsList) {
        this.InitializeButtons(buttonsList);
        dpadLogic = this.GetRootWidget().GetController() as fullscreenDpadSupported;
        if IsDefined(dpadLogic) && buttonsList.GetNumChildren() > 0 {
          firstButton = buttonsList.GetWidget(0);
          dpadLogic.SetDpadTargetsInList(buttonsList);
          dpadLogic.SetDpadTargets(null, firstButton, null, firstButton);
          this.SetCursorOverWidget(firstButton);
        };
      };
    };
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
  }

  public func InitializeMenuName(menuName: wref<inkText>) -> Void;

  public func InitializeButtons(buttonsList: wref<inkVerticalPanel>) -> Void;

  protected final func AddButton(buttonsList: ref<inkVerticalPanel>, text: String, callBackName: CName) -> Void {
    let currLogic: wref<inkButtonDpadSupportedController>;
    let newButton: wref<inkWidget> = this.SpawnFromExternal(buttonsList, r"base\\gameplay\\gui\\fullscreen\\main_menu\\shared_data.inkwidget", n"MenuButton");
    newButton.RegisterToCallback(n"OnRelease", this, callBackName);
    currLogic = newButton.GetController() as inkButtonDpadSupportedController;
    currLogic.SetButtonText(text);
  }

  protected final func AddBigButton(buttonsList: ref<inkCompoundWidget>, text: String, callBackName: CName) -> Void {
    let currLogic: wref<inkButtonAnimatedController>;
    let newButton: wref<inkWidget> = this.SpawnFromExternal(buttonsList, r"base\\gameplay\\gui\\fullscreen\\main_menu\\shared_data.inkwidget", n"BigButton");
    newButton.RegisterToCallback(n"OnRelease", this, callBackName);
    currLogic = newButton.GetController() as inkButtonAnimatedController;
    currLogic.SetButtonText(text);
  }

  protected final func AddSelector(selectorsList: ref<inkVerticalPanel>, label: String, opt values: array<String>) -> wref<SelectorController> {
    let newSelector: wref<inkWidget> = this.SpawnFromExternal(selectorsList, r"base\\gameplay\\gui\\fullscreen\\main_menu\\shared_data.inkwidget", n"MenuSelector");
    let currLogic: wref<SelectorController> = newSelector.GetController() as SelectorController;
    currLogic.SetLabel(label);
    currLogic.AddValues(values);
    if ArraySize(values) > 0 {
      currLogic.SetCurrIndex(0);
    };
    return currLogic;
  }
}
