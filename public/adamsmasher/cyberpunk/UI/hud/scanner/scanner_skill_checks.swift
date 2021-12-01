
public class ScannerSkillCheckLogicController extends inkLogicController {

  @default(ScannerSkillCheckLogicController, SkillCheckItem)
  private edit let m_ScannerSkillCheckItemName: CName;

  private let m_SkillCheckObjects: array<wref<inkWidget>>;

  public let m_Root: wref<inkCompoundWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_Root = this.GetRootWidget() as inkCompoundWidget;
  }

  protected cb func OnUninitialize() -> Bool {
    let currObject: wref<inkWidget>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_SkillCheckObjects);
    while i < limit {
      currObject = this.m_SkillCheckObjects[i];
      this.m_Root.RemoveChild(currObject);
      i += 1;
    };
    ArrayClear(this.m_SkillCheckObjects);
  }

  public final func Setup(skillCheckInfo: array<UIInteractionSkillCheck>) -> Void {
    let currLogic: ref<ScannerSkillCheckItemLogicController>;
    let currObject: wref<inkWidget>;
    let sizeSkill: Int32 = ArraySize(skillCheckInfo);
    let sizeList: Int32 = ArraySize(this.m_SkillCheckObjects);
    let i: Int32 = 0;
    let limit: Int32 = Max(sizeSkill, sizeList);
    while i < limit {
      if i < sizeSkill {
        if i < sizeList {
          currObject = this.m_SkillCheckObjects[i];
        } else {
          currObject = this.CreateSkillCheckObject();
        };
        currLogic = currObject.GetController() as ScannerSkillCheckItemLogicController;
        if IsDefined(currLogic) {
          currLogic.Setup(skillCheckInfo[i]);
        };
      } else {
        this.m_Root.RemoveChild(ArrayPop(this.m_SkillCheckObjects));
      };
      i += 1;
    };
    this.m_Root.SetVisible(ArraySize(this.m_SkillCheckObjects) > 0);
  }

  private final func CreateSkillCheckObject() -> wref<inkWidget> {
    let newObject: wref<inkWidget> = this.SpawnFromLocal(this.m_Root, this.m_ScannerSkillCheckItemName);
    ArrayPush(this.m_SkillCheckObjects, newObject);
    return newObject;
  }
}

public class ScannerSkillCheckItemLogicController extends inkLogicController {

  private edit let m_NameRef: inkTextRef;

  private edit let m_ConditionDataListRef: inkCompoundRef;

  private let m_ConditionDataItems: array<wref<inkWidget>>;

  @default(ScannerSkillCheckItemLogicController, ConditionDataItem)
  private edit let m_ConditionDataItemName: CName;

  @default(ScannerSkillCheckItemLogicController, Passed)
  private edit let m_PassedStateName: CName;

  @default(ScannerSkillCheckItemLogicController, Failed)
  private edit let m_FailedStateName: CName;

  protected cb func OnUninitialize() -> Bool {
    let currObject: wref<inkWidget>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_ConditionDataItems);
    while i < limit {
      currObject = this.m_ConditionDataItems[i];
      inkCompoundRef.RemoveChild(this.m_ConditionDataListRef, currObject);
      i += 1;
    };
    ArrayClear(this.m_ConditionDataItems);
  }

  public final func Setup(skillCheck: UIInteractionSkillCheck) -> Void {
    let currLogic: ref<ScannerSkillCheckConditionDataItemLogicController>;
    let currObject: wref<inkWidget>;
    let i: Int32;
    let limit: Int32;
    let sizeList: Int32;
    let sizeSkill: Int32;
    this.ConstructName(skillCheck);
    this.GetRootWidget().SetState(skillCheck.isPassed ? this.m_PassedStateName : this.m_FailedStateName);
    sizeSkill = ArraySize(skillCheck.additionalRequirements);
    sizeList = ArraySize(this.m_ConditionDataItems);
    i = 0;
    limit = Max(sizeSkill, sizeList);
    while i < limit {
      if i < sizeSkill {
        if i < sizeList {
          currObject = this.m_ConditionDataItems[i];
        } else {
          currObject = this.CreateConditionDataObject();
        };
        currLogic = currObject.GetController() as ScannerSkillCheckConditionDataItemLogicController;
        if IsDefined(currLogic) {
          currLogic.Setup(skillCheck.additionalRequirements[i], skillCheck.additionalReqOperator);
        };
      } else {
        inkCompoundRef.RemoveChild(this.m_ConditionDataListRef, ArrayPop(this.m_ConditionDataItems));
      };
      i += 1;
    };
  }

  private final func CreateConditionDataObject() -> wref<inkWidget> {
    let newObject: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_ConditionDataListRef), this.m_ConditionDataItemName);
    ArrayPush(this.m_ConditionDataItems, newObject);
    return newObject;
  }

  private final func ConstructName(skillCheck: UIInteractionSkillCheck) -> Void {
    let hasActionName: Bool = StrLen(skillCheck.actionDisplayName) > 0;
    let skillName: String = "";
    if hasActionName {
      skillName += skillCheck.actionDisplayName + " (";
    };
    skillName += GetLocalizedText(skillCheck.skillName) + " " + ToString(skillCheck.requiredSkill);
    if hasActionName {
      skillName += ")";
    };
    inkTextRef.SetLetterCase(this.m_NameRef, textLetterCase.UpperCase);
    inkTextRef.SetText(this.m_NameRef, skillName);
  }
}

public class ScannerSkillCheckConditionDataItemLogicController extends inkLogicController {

  @default(ScannerSkillCheckConditionDataItemLogicController, ConditionDataDescription)
  private edit let m_ConditionDataDescriptionName: CName;

  private edit let m_ParentConditionTextPath: inkWidgetPath;

  private edit let m_OwnConditionTextPath: inkWidgetPath;

  private edit let m_ConditionDescriptionListPath: inkWidgetPath;

  private let m_ConditionDescriptions: array<wref<inkWidget>>;

  private let m_ParentConditionText: wref<inkText>;

  private let m_OwnConditionText: wref<inkText>;

  private let m_ConditionDescriptionList: wref<inkCompoundWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_ParentConditionText = this.GetWidget(this.m_ParentConditionTextPath) as inkText;
    this.m_OwnConditionText = this.GetWidget(this.m_OwnConditionTextPath) as inkText;
    this.m_ConditionDescriptionList = this.GetWidget(this.m_ConditionDescriptionListPath) as inkCompoundWidget;
  }

  protected cb func OnUninitialize() -> Bool {
    let currObject: wref<inkWidget>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_ConditionDescriptions);
    while i < limit {
      currObject = this.m_ConditionDescriptions[i];
      this.m_ConditionDescriptionList.RemoveChild(currObject);
      i += 1;
    };
    ArrayClear(this.m_ConditionDescriptions);
  }

  public final func Setup(conditionData: ConditionData, parentOperator: ELogicOperator) -> Void {
    let currLogic: ref<ScannerSkillCheckConditionDescriptionLogicController>;
    let currObject: wref<inkWidget>;
    let sizeSkill: Int32 = ArraySize(conditionData.requirementList);
    let sizeList: Int32 = ArraySize(this.m_ConditionDescriptions);
    let numPassed: Int32 = 0;
    let i: Int32 = 0;
    let limit: Int32 = Max(sizeSkill, sizeList);
    while i < limit {
      if i < sizeSkill {
        if i < sizeList {
          currObject = this.m_ConditionDescriptions[i];
        } else {
          currObject = this.CreateConditionDescriptionObject();
        };
        currLogic = currObject.GetController() as ScannerSkillCheckConditionDescriptionLogicController;
        if IsDefined(currLogic) {
          currLogic.Setup(conditionData.requirementList[i]);
          if conditionData.requirementList[i].passed {
            numPassed += 1;
          };
        };
      } else {
        this.m_ConditionDescriptionList.RemoveChild(ArrayPop(this.m_ConditionDescriptions));
      };
      i += 1;
    };
    this.ConstructTexts(conditionData.conditionOperator, parentOperator, numPassed, sizeSkill);
  }

  private final func CreateConditionDescriptionObject() -> wref<inkWidget> {
    let newObject: wref<inkWidget> = this.SpawnFromLocal(this.m_ConditionDescriptionList, this.m_ConditionDataDescriptionName);
    ArrayPush(this.m_ConditionDescriptions, newObject);
    return newObject;
  }

  private final func ConstructTexts(ownOperator: ELogicOperator, parentOperator: ELogicOperator, passed: Int32, total: Int32) -> Void {
    let conditionText: String;
    this.m_ParentConditionText.SetLetterCase(textLetterCase.UpperCase);
    this.m_ParentConditionText.SetText(ToString(parentOperator));
    conditionText = "(any 1 needed)";
    if Equals(ownOperator, ELogicOperator.AND) {
      conditionText = "(" + passed + "/" + total + ")";
    };
    this.m_OwnConditionText.SetLetterCase(textLetterCase.UpperCase);
    this.m_OwnConditionText.SetText(conditionText);
  }
}

public class ScannerSkillCheckConditionDescriptionLogicController extends inkLogicController {

  private edit let m_NameRef: inkTextRef;

  @default(ScannerSkillCheckConditionDescriptionLogicController, Passed)
  private edit let m_PassedStateName: CName;

  @default(ScannerSkillCheckConditionDescriptionLogicController, Failed)
  private edit let m_FailedStateName: CName;

  public final func Setup(condition: Condition) -> Void {
    this.GetRootWidget().SetState(condition.passed ? this.m_PassedStateName : this.m_FailedStateName);
    inkTextRef.SetLocalizedTextScript(this.m_NameRef, condition.description);
  }
}
