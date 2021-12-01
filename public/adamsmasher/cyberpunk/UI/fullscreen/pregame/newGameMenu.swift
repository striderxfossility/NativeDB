
public class NewGameMenuGameController extends PreGameSubMenuGameController {

  private let m_categories: wref<SelectorController>;

  private let m_gameDefinitions: wref<SelectorController>;

  private let m_genders: wref<SelectorController>;

  protected cb func OnInitialize() -> Bool {
    let bigButtonsList: wref<inkHorizontalPanel> = this.GetWidget(n"Data/StaticBigButtonsList") as inkHorizontalPanel;
    this.AddBigButton(bigButtonsList, "RUN FUNC. TEST MAP", n"OnRunFunctionalTestMap");
    this.SetCursorOverWidget(bigButtonsList.GetWidget(0));
    this.InitDynamicButtons();
    this.InitSelectors();
  }

  protected cb func OnRunFunctionalTestMap(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.GetSystemRequestsHandler().RunUiFunctionalTestWorld();
    };
  }

  protected cb func OnStartDefinition(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.GetSystemRequestsHandler().StartGameDefinition(this.m_categories.GetCurrIndex(), this.m_gameDefinitions.GetCurrIndex(), this.m_genders.GetCurrIndex());
    };
  }

  protected cb func OnCategoryChanged(index: Int32, value: String) -> Bool {
    let values: array<String> = this.GetSystemRequestsHandler().GetGameDefinitions(this.m_categories.GetCurrIndex());
    this.m_gameDefinitions.Clear();
    this.m_gameDefinitions.AddValues(values);
    if ArraySize(values) > 0 {
      this.m_gameDefinitions.SetCurrIndex(0);
    };
  }

  protected cb func OnBack(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnBack");
    };
  }

  public final func InitDynamicButtons() -> Void {
    let bigButtonsList: wref<inkHorizontalPanel> = this.GetWidget(n"Data/DynamicBigButtonsList") as inkHorizontalPanel;
    bigButtonsList.RemoveAllChildren();
    this.AddBigButton(bigButtonsList, "START GAMEDEF", n"OnStartDefinition");
    this.AddBigButton(bigButtonsList, "BACK", n"OnBack");
  }

  public final func InitSelectors() -> Void {
    let handler: wref<inkISystemRequestsHandler> = this.GetSystemRequestsHandler();
    let selectorsList: wref<inkVerticalPanel> = this.GetWidget(n"Data/Selectors") as inkVerticalPanel;
    selectorsList.RemoveAllChildren();
    this.m_categories = this.AddSelector(selectorsList, "Category:", handler.GetGameDefCategories());
    this.m_categories.RegisterToCallback(n"OnSelectionChanged", this, n"OnCategoryChanged");
    this.m_gameDefinitions = this.AddSelector(selectorsList, "Definition:", handler.GetGameDefinitions(this.m_categories.GetCurrIndex()));
    this.m_genders = this.AddSelector(selectorsList, "Gender:", handler.GetGenders());
  }
}
