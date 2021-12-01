
public static func OperatorEqual(documentAdress1: SDocumentAdress, documentAdress2: SDocumentAdress) -> Bool {
  if documentAdress1.folderID == documentAdress2.folderID && documentAdress1.documentID == documentAdress2.documentID {
    return true;
  };
  return false;
}

public class ComputerDocumentThumbnailWidgetController extends DeviceButtonLogicControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_documentIconWidget: inkImageRef;

  protected let m_documentAdress: SDocumentAdress;

  protected let m_documentType: EDocumentType;

  protected let m_questInfo: QuestInfo;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.SetSelectable(true);
  }

  public func Initialize(gameController: ref<ComputerInkGameController>, widgetData: SDocumentThumbnailWidgetPackage) -> Void {
    this.RegisterThumbnailCallback(gameController);
    inkTextRef.SetText(this.m_displayNameWidget, widgetData.displayName);
    this.m_documentAdress = widgetData.documentAdress;
    this.m_documentType = widgetData.documentType;
    this.m_questInfo = widgetData.questInfo;
    if widgetData.wasRead {
      this.OpenDocument();
    } else {
      this.CloseDocument();
    };
    this.m_isInitialized = true;
    if Equals(this.m_documentType, gameController.GetForceOpenDocumentType()) && this.m_documentAdress == gameController.GetForceOpenDocumentAdress() {
      gameController.OpenDocument(this);
      gameController.ResetForceOpenDocumentData();
    };
  }

  protected final func RegisterThumbnailCallback(gameController: ref<ComputerInkGameController>) -> Void {
    if !this.m_isInitialized {
      this.m_targetWidget.RegisterToCallback(n"OnRelease", gameController, n"OnDocumentThumbnailCallback");
      this.RegisterAudioCallbacks(gameController);
    };
  }

  public func ResolveSelection() -> Void {
    this.ResolveSelection();
    if this.GetSelected() {
    };
  }

  public final func OpenDocument() -> Void {
    if Equals(this.m_documentType, EDocumentType.MAIL) {
      inkImageRef.SetTexturePart(this.m_documentIconWidget, n"iconMailRead");
    } else {
      if Equals(this.m_documentType, EDocumentType.FILE) {
        inkImageRef.SetTexturePart(this.m_documentIconWidget, n"iconMailRead");
      };
    };
  }

  public final func CloseDocument() -> Void {
    if Equals(this.m_documentType, EDocumentType.MAIL) {
      inkImageRef.SetTexturePart(this.m_documentIconWidget, n"iconMailUnread");
    } else {
      if Equals(this.m_documentType, EDocumentType.FILE) {
        inkImageRef.SetTexturePart(this.m_documentIconWidget, n"iconMailUnread");
      };
    };
  }

  public final func GetDocumentAdress() -> SDocumentAdress {
    return this.m_documentAdress;
  }

  public final func GetDocumentType() -> EDocumentType {
    return this.m_documentType;
  }

  public final func GetQuestInfo() -> QuestInfo {
    return this.m_questInfo;
  }
}
