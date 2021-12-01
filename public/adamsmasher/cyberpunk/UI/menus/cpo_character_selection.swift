
public class CpoCharacterButtonItemController extends inkButtonDpadSupportedController {

  private let m_characterRecordId: TweakDBID;

  public final func SetButtonDetails(text: String, characterRecordId: TweakDBID) -> Void {
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    let currListText: wref<inkText> = this.m_rootWidget.GetWidget(n"textLabel") as inkText;
    currListText.SetText(text);
    this.m_characterRecordId = characterRecordId;
  }

  public final func GetCharacterRecordId() -> TweakDBID {
    return this.m_characterRecordId;
  }
}

public class CpoCharacterSelectionWidgetGameController extends inkGameController {

  public edit let m_defaultCharacterTexturePart: String;

  public edit let m_soloCharacterTexturePart: String;

  private let m_horizontalPanelsList: array<wref<inkHorizontalPanel>>;

  @default(CpoCharacterSelectionWidgetGameController, 5)
  private let m_amount: Int32;

  protected cb func OnInitialize() -> Bool {
    let verticalPanel: wref<inkVerticalPanel> = this.GetWidget(n"SubCanvas\\VerticalPanel") as inkVerticalPanel;
    let horizontalList1: wref<inkHorizontalPanel> = this.SpawnFromLocal(verticalPanel, n"CpoCharactersList") as inkHorizontalPanel;
    let horizontalList2: wref<inkHorizontalPanel> = this.SpawnFromLocal(verticalPanel, n"CpoCharactersList") as inkHorizontalPanel;
    let horizontalList3: wref<inkHorizontalPanel> = this.SpawnFromLocal(verticalPanel, n"CpoCharactersList") as inkHorizontalPanel;
    this.CreateCharacterButton(horizontalList1, "Default", t"Character.Cpo_Default_Player");
    this.CreateCharacterButton(horizontalList1, "Solo", t"Character.Cpo_Solo");
    this.CreateCharacterButton(horizontalList1, "Assassin", t"Character.Cpo_Assassin");
    this.CreateCharacterButton(horizontalList2, "Techie", t"Character.Cpo_Techie");
    this.CreateCharacterButton(horizontalList2, "Netrunner", t"Character.Cpo_Netrunner");
    this.CreateCharacterButton(horizontalList2, "Solo[M]", t"Character.Cpo_Muppet_Solo");
    this.CreateCharacterButton(horizontalList3, "Assassin[M]", t"Character.Cpo_Muppet_Assassin");
    this.CreateCharacterButton(horizontalList3, "Techie[M]", t"Character.Cpo_Muppet_Techie");
    this.CreateCharacterButton(horizontalList3, "Netrunner[M]", t"Character.Cpo_Muppet_Netrunner");
    this.SetCursorOverWidget(horizontalList1.GetWidget(0));
    this.SetVisibilityInBlackboard(true);
  }

  protected cb func OnUninitialize() -> Bool {
    this.SetVisibilityInBlackboard(false);
  }

  private final func CreateCharacterButton(parent: wref<inkHorizontalPanel>, argText: String, characterRecordId: TweakDBID) -> Void {
    let currLogic: wref<CpoCharacterButtonItemController>;
    let currButton: wref<inkCanvas> = this.SpawnFromLocal(parent, n"CpoCharacterButton") as inkCanvas;
    currButton.RegisterToCallback(n"OnRelease", this, n"OnSelectCharacter");
    currButton.RegisterToCallback(n"OnEnter", this, n"OnSelectCharacterEnter");
    currButton.RegisterToCallback(n"OnLeave", this, n"OnSelectCharacterLeave");
    currLogic = currButton.GetController() as CpoCharacterButtonItemController;
    currLogic.SetButtonDetails(argText, characterRecordId);
  }

  public final func OnSelectCharacter(e: ref<inkPointerEvent>) -> Void {
    let bb: ref<IBlackboard>;
    let button: wref<inkCanvas>;
    let controller: wref<CpoCharacterButtonItemController>;
    if e.IsAction(n"click") {
      button = e.GetCurrentTarget() as inkCanvas;
      controller = button.GetController() as CpoCharacterButtonItemController;
      Log("Selecting CPO character class: " + TDBID.ToStringDEBUG(controller.GetCharacterRecordId()));
      bb = GameInstance.GetBlackboardSystem((this.GetOwnerEntity() as GameObject).GetGame()).Get(GetAllBlackboardDefs().UI_CpoCharacterSelection);
      bb.SetVariant(GetAllBlackboardDefs().UI_CpoCharacterSelection.CharacterRecordId, ToVariant(controller.GetCharacterRecordId()));
      bb.SignalVariant(GetAllBlackboardDefs().UI_CpoCharacterSelection.CharacterRecordId);
    };
  }

  public final func OnSelectCharacterEnter(e: ref<inkPointerEvent>) -> Void {
    let button: wref<inkWidget> = e.GetCurrentTarget();
    let controller: wref<CpoCharacterButtonItemController> = button.GetController() as CpoCharacterButtonItemController;
    this.FillTooltip(controller.GetCharacterRecordId());
    this.ShowTooltip(true);
  }

  public final func OnSelectCharacterLeave(e: ref<inkPointerEvent>) -> Void {
    this.ShowTooltip(false);
  }

  private final func FillTooltip(characterRecordId: TweakDBID) -> Void {
    let tooltipWidgetText: wref<inkText> = this.GetWidget(n"SubCanvas/tooltip/tooltipText") as inkText;
    let tooltipWidgetText2: wref<inkText> = this.GetWidget(n"SubCanvas/tooltip/tooltipText2") as inkText;
    let character: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(characterRecordId);
    tooltipWidgetText.SetLocalizedTextScript(character.DisplayName());
    tooltipWidgetText2.SetLocalizedTextScript(character.DisplayDescription());
  }

  private final func ShowTooltip(visible: Bool) -> Void {
    let tooltipWidget: wref<inkCanvas> = this.GetWidget(n"SubCanvas\\tooltip") as inkCanvas;
    tooltipWidget.SetVisible(visible);
  }

  private final func SetVisibilityInBlackboard(isVisible: Bool) -> Void {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem((this.GetOwnerEntity() as GameObject).GetGame()).Get(GetAllBlackboardDefs().UI_CpoCharacterSelection);
    bb.SetBool(GetAllBlackboardDefs().UI_CpoCharacterSelection.SelectionMenuVisible, isVisible);
    bb.SignalBool(GetAllBlackboardDefs().UI_CpoCharacterSelection.SelectionMenuVisible);
  }
}
