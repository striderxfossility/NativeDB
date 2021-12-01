
public class ScannerQuestClue extends inkLogicController {

  private edit let m_CategoryTextRef: inkTextRef;

  private edit let m_DescriptionTextRef: inkTextRef;

  private edit let m_IconRef: inkImageRef;

  public final func Setup(questEntry: ref<IScriptable>) -> Void {
    let iconName: CName;
    let iconRecord: ref<UIIcon_Record>;
    let record: ref<ScannableData_Record>;
    let questEntryUserData: ref<QuestEntryUserData> = questEntry as QuestEntryUserData;
    if !IsNameValid(questEntryUserData.categoryName) && !IsNameValid(questEntryUserData.entryName) {
      this.GetRootWidget().SetVisible(false);
      return;
    };
    this.GetRootWidget().SetVisible(true);
    record = TweakDBInterface.GetScannableDataRecord(questEntryUserData.recordID);
    if record != null {
      iconRecord = record.IconRecord();
      if iconRecord != null {
        this.SetTexture(this.m_IconRef, iconRecord.GetID());
        inkWidgetRef.SetVisible(this.m_IconRef, true);
      } else {
        iconName = record.IconName();
        if IsNameValid(iconName) {
          inkImageRef.SetTexturePart(this.m_IconRef, iconName);
          inkWidgetRef.SetVisible(this.m_IconRef, true);
        } else {
          inkWidgetRef.SetVisible(this.m_IconRef, false);
        };
      };
    };
    inkTextRef.SetLocalizedTextScript(this.m_CategoryTextRef, questEntryUserData.categoryName);
    inkTextRef.SetLocalizedTextScript(this.m_DescriptionTextRef, questEntryUserData.entryName);
  }
}
