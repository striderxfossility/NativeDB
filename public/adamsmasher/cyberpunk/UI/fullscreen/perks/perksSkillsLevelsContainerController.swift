
public class PerksSkillsLevelsContainerController extends inkLogicController {

  protected edit let m_topRowItemsContainer: inkCompoundRef;

  protected edit let m_bottomRowItemsContainer: inkCompoundRef;

  protected edit let m_levelBar: inkWidgetRef;

  protected edit let m_levelBarSpacer: inkWidgetRef;

  protected edit let m_label: inkTextRef;

  protected let m_proficiencyDisplayData: ref<ProficiencyDisplayData>;

  public final func Setup(proficiencyDisplayData: ref<ProficiencyDisplayData>) -> Void {
    this.m_proficiencyDisplayData = proficiencyDisplayData;
    inkTextRef.SetText(this.m_label, this.m_proficiencyDisplayData.m_localizedName);
    this.UpdateLevelsIndicators();
    this.UpdateLevelBar();
  }

  public final func UpdateLevelsIndicators() -> Void {
    let i: Int32;
    let widget: wref<inkWidget>;
    inkCompoundRef.RemoveAllChildren(this.m_topRowItemsContainer);
    inkCompoundRef.RemoveAllChildren(this.m_bottomRowItemsContainer);
    i = 0;
    while i < ArraySize(this.m_proficiencyDisplayData.m_areas) {
      if i < 5 {
        widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_topRowItemsContainer), n"SkillPerkLevelPreview");
      } else {
        widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_bottomRowItemsContainer), n"SkillPerkLevelPreview");
      };
      (widget.GetController() as PerksSkillsLevelDisplayController).Setup(this.m_proficiencyDisplayData.m_areas[i]);
      i += 1;
    };
  }

  public final func UpdateLevelBar() -> Void {
    let percentage: Float;
    if this.m_proficiencyDisplayData.m_level == this.m_proficiencyDisplayData.m_maxLevel {
      percentage = 100.00;
    } else {
      percentage = Cast(this.m_proficiencyDisplayData.m_expPoints) / Cast(this.m_proficiencyDisplayData.m_maxExpPoints) * 100.00;
    };
    inkWidgetRef.SetSizeCoefficient(this.m_levelBar, percentage);
    inkWidgetRef.SetSizeCoefficient(this.m_levelBarSpacer, 100.00 - percentage);
  }
}

public class PerksSkillsLevelDisplayController extends inkLogicController {

  protected edit let m_tint: inkWidgetRef;

  public final func Setup(data: ref<AreaDisplayData>) -> Void {
    let boughtMax: Int32;
    let boughtSum: Int32;
    let maxedSum: Int32;
    let perk: ref<PerkDisplayData>;
    let state: CName;
    let i: Int32 = 0;
    while i < ArraySize(data.m_perks) {
      perk = data.m_perks[i];
      if perk.m_level == perk.m_maxLevel {
        maxedSum += 1;
      };
      boughtSum += perk.m_level;
      boughtMax += perk.m_maxLevel - 1;
      i += 1;
    };
    if maxedSum > 0 {
      state = n"Maxed";
      inkWidgetRef.SetOpacity(this.m_tint, Cast(maxedSum) / Cast(ArraySize(data.m_perks)));
    } else {
      if boughtSum > 0 {
        state = n"Bought";
        inkWidgetRef.SetOpacity(this.m_tint, Cast(boughtSum) / Cast(boughtMax));
      } else {
        inkWidgetRef.SetOpacity(this.m_tint, 0.00);
      };
    };
    inkWidgetRef.SetState(this.m_tint, state);
  }
}
