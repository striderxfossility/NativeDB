
public class DlcDescriptionController extends inkLogicController {

  private edit let m_titleRef: inkTextRef;

  private edit let m_descriptionRef: inkTextRef;

  private edit let m_guideRef: inkTextRef;

  private edit let m_imageRef: inkImageRef;

  public final func SetData(userData: ref<DlcDescriptionData>) -> Void {
    inkTextRef.SetLocalizedText(this.m_titleRef, userData.m_title);
    inkTextRef.SetLocalizedText(this.m_descriptionRef, userData.m_description);
    inkTextRef.SetLocalizedText(this.m_guideRef, userData.m_guide);
    inkImageRef.SetTexturePart(this.m_imageRef, userData.m_imagePart);
  }
}

public class DlcMenuGameController extends gameuiMenuGameController {

  private edit let m_buttonHintsRef: inkWidgetRef;

  private edit let m_containersRef: inkCompoundRef;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.SpawnInputHints();
    this.SpawnDescriptions(n"UI-DLC-JohnnyAltApp_Title", n"UI-DLC-JohnnyAltApp_Description", n"UI-DLC-JohnnyAltApp_Guide", n"dlc_johnny");
    this.SpawnDescriptions(n"UI-DLC-Jackets_Title", n"UI-DLC-Jackets_Description", n"UI-DLC-Jackets_Guide", n"dlc_jackets");
    this.SpawnDescriptions(n"UI-DLC-Archer_Title", n"UI-DLC-Archer_Description", n"UI-DLC-Archer_Guide", n"dlc_archer");
  }

  private final func SpawnInputHints() -> Void {
    let buttonHintsController: wref<ButtonHints>;
    let path: ResRef;
    let widget: wref<inkWidget>;
    if inkWidgetRef.IsValid(this.m_buttonHintsRef) {
      path = r"base\\gameplay\\gui\\common\\buttonhints.inkwidget";
      widget = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsRef), path, n"Root");
      buttonHintsController = widget.GetController() as ButtonHints;
      buttonHintsController.AddButtonHint(n"back", "Common-Access-Close");
    };
  }

  private final func SpawnDescriptions(title: CName, description: CName, guide: CName, imagePart: CName) -> Void {
    let data: ref<DlcDescriptionData> = new DlcDescriptionData();
    data.m_title = title;
    data.m_description = description;
    data.m_guide = guide;
    data.m_imagePart = imagePart;
    this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_containersRef), n"dlcDescription", this, n"OnDescriptionSpawned", data);
  }

  protected cb func OnDescriptionSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let itemCtrl: wref<DlcDescriptionController>;
    if IsDefined(widget) {
      itemCtrl = widget.GetController() as DlcDescriptionController;
      itemCtrl.SetData(userData as DlcDescriptionData);
    };
  }
}
