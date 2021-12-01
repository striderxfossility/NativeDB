
public class CodexListItemController extends ListItemController {

  protected edit let m_doMarkNew: Bool;

  protected edit let m_stateMapperRef: inkWidgetRef;

  protected let m_stateMapper: wref<ListItemStateMapper>;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnDataChanged", this, n"OnDataChanged");
    this.m_stateMapper = inkWidgetRef.GetControllerByType(this.m_stateMapperRef, n"ListItemStateMapper") as ListItemStateMapper;
  }

  protected cb func OnDataChanged(value: ref<IScriptable>) -> Bool {
    let data: ref<JournalRepresentationData> = value as JournalRepresentationData;
    if this.m_doMarkNew {
      this.m_stateMapper.SetNew(data.IsNew);
    };
    super.OnDataChanged(value);
    data.Reference = this.GetRootWidget();
  }

  protected cb func OnToggledOn(target: wref<ListItemController>) -> Bool {
    this.RemoveNew();
  }

  protected final func RemoveNew() -> Void {
    this.m_stateMapper.SetNew(false);
  }
}

public class CodexImageButton extends CodexListItemController {

  protected edit let m_image: inkImageRef;

  protected edit let m_border: inkImageRef;

  protected edit let m_translateOnSelect: inkWidgetRef;

  protected edit let m_selectTranslationX: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_stateMapper = inkWidgetRef.GetControllerByType(this.m_stateMapperRef, n"ListItemStateMapper") as ListItemStateMapper;
    inkWidgetRef.SetVisible(this.m_border, this.IsToggled());
    this.RegisterToCallback(n"OnToggledOn", this, n"OnToggledOn");
    this.RegisterToCallback(n"OnToggledOff", this, n"OnToggledOff");
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
  }

  protected cb func OnToggledOn(target: wref<ListItemController>) -> Bool {
    this.RemoveNew();
    inkWidgetRef.SetVisible(this.m_border, true);
    if inkWidgetRef.IsValid(this.m_translateOnSelect) {
      inkWidgetRef.SetTranslation(this.m_translateOnSelect, this.m_selectTranslationX, 0.00);
    };
  }

  protected cb func OnToggledOff(target: wref<ListItemController>) -> Bool {
    inkWidgetRef.SetVisible(this.m_border, false);
    if inkWidgetRef.IsValid(this.m_translateOnSelect) {
      inkWidgetRef.SetTranslation(this.m_translateOnSelect, 0.00, 0.00);
    };
  }

  protected cb func OnDataChanged(value: ref<IScriptable>) -> Bool {
    let data: wref<JournalRepresentationData>;
    let image: CName;
    let journalData: wref<JournalCodexCategory>;
    super.OnDataChanged(value);
    data = value as JournalRepresentationData;
    journalData = data.Data as JournalCodexCategory;
    if IsDefined(journalData) {
      inkWidgetRef.SetVisible(this.m_labelPathRef, false);
      image = StringToName(journalData.GetCategoryName());
    } else {
      if IsDefined(data.OnscreenData) {
        inkWidgetRef.SetVisible(this.m_labelPathRef, false);
        image = data.OnscreenData.GetTag();
      } else {
        inkWidgetRef.SetVisible(this.m_labelPathRef, true);
        image = n"";
      };
    };
    if inkWidgetRef.IsValid(this.m_image) {
      if IsNameValid(image) {
        inkWidgetRef.SetVisible(this.m_image, true);
        inkImageRef.SetTexturePart(this.m_image, image);
      } else {
        inkWidgetRef.SetVisible(this.m_image, false);
      };
    };
  }

  protected func ExtractImage(data: ref<JournalRepresentationData>) -> CName {
    return n"";
  }
}
