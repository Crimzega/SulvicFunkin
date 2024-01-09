package funkin.ui.debug.charting.handlers;

import funkin.play.stage.StageData.StageDataParser;
import funkin.play.stage.StageData;
import funkin.play.character.CharacterData;
import funkin.play.character.CharacterData.CharacterDataParser;
import haxe.ui.components.HorizontalSlider;
import haxe.ui.containers.TreeView;
import haxe.ui.containers.TreeViewNode;
import funkin.play.character.BaseCharacter.CharacterType;
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.song.SongData.SongTimeChange;
import funkin.play.character.BaseCharacter.CharacterType;
import funkin.play.character.CharacterData;
import funkin.play.character.CharacterData.CharacterDataParser;
import funkin.play.event.SongEvent;
import funkin.play.song.SongSerializer;
import funkin.play.stage.StageData;
import funkin.play.stage.StageData.StageDataParser;
import haxe.ui.RuntimeComponentBuilder;
import funkin.ui.debug.charting.util.ChartEditorDropdowns;
import funkin.ui.haxeui.components.CharacterPlayer;
import funkin.util.FileUtil;
import haxe.ui.components.Button;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.components.CheckBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.HorizontalSlider;
import haxe.ui.components.Label;
import haxe.ui.components.NumberStepper;
import haxe.ui.components.Slider;
import haxe.ui.components.TextField;
import haxe.ui.containers.Box;
import haxe.ui.containers.dialogs.CollapsibleDialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import funkin.ui.debug.charting.toolboxes.ChartEditorBaseToolbox;
import funkin.ui.debug.charting.toolboxes.ChartEditorMetadataToolbox;
import funkin.ui.debug.charting.toolboxes.ChartEditorEventDataToolbox;
import haxe.ui.containers.Frame;
import haxe.ui.containers.Grid;
import haxe.ui.containers.TreeView;
import haxe.ui.containers.TreeViewNode;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;

/**
 * Static functions which handle building themed UI elements for a provided ChartEditorState.
 */
@:nullSafety
@:access(funkin.ui.debug.charting.ChartEditorState)
class ChartEditorToolboxHandler
{
  public static function setToolboxState(state:ChartEditorState, id:String, shown:Bool):Void
  {
    if (shown)
    {
      showToolbox(state, id);
    }
    else
    {
      hideToolbox(state, id);
    }
  }

  public static function showToolbox(state:ChartEditorState, id:String):Void
  {
    var toolbox:Null<CollapsibleDialog> = state.activeToolboxes.get(id);

    if (toolbox == null) toolbox = initToolbox(state, id);

    if (toolbox != null)
    {
      toolbox.showDialog(false);

      state.playSound(Paths.sound('chartingSounds/openWindow'));

      switch (id)
      {
        case ChartEditorState.CHART_EDITOR_TOOLBOX_NOTEDATA_LAYOUT:
          onShowToolboxNoteData(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_EVENT_DATA_LAYOUT:
          // TODO: Fix this.
          cast(toolbox, ChartEditorBaseToolbox).refresh();
        case ChartEditorState.CHART_EDITOR_TOOLBOX_PLAYTEST_PROPERTIES_LAYOUT:
          onShowToolboxPlaytestProperties(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_DIFFICULTY_LAYOUT:
          onShowToolboxDifficulty(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_METADATA_LAYOUT:
          // TODO: Fix this.
          cast(toolbox, ChartEditorBaseToolbox).refresh();
        case ChartEditorState.CHART_EDITOR_TOOLBOX_PLAYER_PREVIEW_LAYOUT:
          onShowToolboxPlayerPreview(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_OPPONENT_PREVIEW_LAYOUT:
          onShowToolboxOpponentPreview(state, toolbox);
        default:
          // This happens if you try to load an unknown layout.
          trace('ChartEditorToolboxHandler.showToolbox() - Unknown toolbox ID: $id');
      }
    }
    else
    {
      trace('ChartEditorToolboxHandler.showToolbox() - Could not retrieve toolbox: $id');
    }
  }

  public static function hideToolbox(state:ChartEditorState, id:String):Void
  {
    var toolbox:Null<CollapsibleDialog> = state.activeToolboxes.get(id);

    if (toolbox == null) toolbox = initToolbox(state, id);

    if (toolbox != null)
    {
      toolbox.hideDialog(DialogButton.CANCEL);

      state.playSound(Paths.sound('chartingSounds/exitWindow'));

      switch (id)
      {
        case ChartEditorState.CHART_EDITOR_TOOLBOX_NOTEDATA_LAYOUT:
          onHideToolboxNoteData(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_EVENT_DATA_LAYOUT:
          onHideToolboxEventData(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_PLAYTEST_PROPERTIES_LAYOUT:
          onHideToolboxPlaytestProperties(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_DIFFICULTY_LAYOUT:
          onHideToolboxDifficulty(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_METADATA_LAYOUT:
          onHideToolboxMetadata(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_PLAYER_PREVIEW_LAYOUT:
          onHideToolboxPlayerPreview(state, toolbox);
        case ChartEditorState.CHART_EDITOR_TOOLBOX_OPPONENT_PREVIEW_LAYOUT:
          onHideToolboxOpponentPreview(state, toolbox);
        default:
          // This happens if you try to load an unknown layout.
          trace('ChartEditorToolboxHandler.hideToolbox() - Unknown toolbox ID: $id');
      }
    }
    else
    {
      trace('ChartEditorToolboxHandler.hideToolbox() - Could not retrieve toolbox: $id');
    }
  }

  public static function refreshToolbox(state:ChartEditorState, id:String):Void
  {
    var toolbox:Null<ChartEditorBaseToolbox> = cast state.activeToolboxes.get(id);

    if (toolbox == null) return;

    if (toolbox != null)
    {
      toolbox.refresh();
    }
    else
    {
      trace('ChartEditorToolboxHandler.refreshToolbox() - Could not retrieve toolbox: $id');
    }
  }

  public static function rememberOpenToolboxes(state:ChartEditorState):Void {}

  public static function openRememberedToolboxes(state:ChartEditorState):Void {}

  public static function hideAllToolboxes(state:ChartEditorState):Void
  {
    for (toolbox in state.activeToolboxes.values())
    {
      toolbox.hideDialog(DialogButton.CANCEL);
    }
  }

  public static function minimizeToolbox(state:ChartEditorState, id:String):Void
  {
    var toolbox:Null<CollapsibleDialog> = state.activeToolboxes.get(id);

    if (toolbox == null) return;

    toolbox.minimized = true;
  }

  public static function maximizeToolbox(state:ChartEditorState, id:String):Void
  {
    var toolbox:Null<CollapsibleDialog> = state.activeToolboxes.get(id);

    if (toolbox == null) return;

    toolbox.minimized = false;
  }

  public static function initToolbox(state:ChartEditorState, id:String):Null<CollapsibleDialog>
  {
    var toolbox:Null<CollapsibleDialog> = null;
    switch (id)
    {
      case ChartEditorState.CHART_EDITOR_TOOLBOX_NOTEDATA_LAYOUT:
        toolbox = buildToolboxNoteDataLayout(state);
      case ChartEditorState.CHART_EDITOR_TOOLBOX_EVENT_DATA_LAYOUT:
        toolbox = buildToolboxEventDataLayout(state);
      case ChartEditorState.CHART_EDITOR_TOOLBOX_PLAYTEST_PROPERTIES_LAYOUT:
        toolbox = buildToolboxPlaytestPropertiesLayout(state);
      case ChartEditorState.CHART_EDITOR_TOOLBOX_DIFFICULTY_LAYOUT:
        toolbox = buildToolboxDifficultyLayout(state);
      case ChartEditorState.CHART_EDITOR_TOOLBOX_METADATA_LAYOUT:
        toolbox = buildToolboxMetadataLayout(state);
      case ChartEditorState.CHART_EDITOR_TOOLBOX_PLAYER_PREVIEW_LAYOUT:
        toolbox = buildToolboxPlayerPreviewLayout(state);
      case ChartEditorState.CHART_EDITOR_TOOLBOX_OPPONENT_PREVIEW_LAYOUT:
        toolbox = buildToolboxOpponentPreviewLayout(state);
      default:
        // This happens if you try to load an unknown layout.
        trace('ChartEditorToolboxHandler.initToolbox() - Unknown toolbox ID: $id');
        toolbox = null;
    }

    // This happens if the layout you try to load has a syntax error.
    if (toolbox == null) return null;

    // Make sure we can reuse the toolbox later.
    toolbox.destroyOnClose = false;
    state.activeToolboxes.set(id, toolbox);

    return toolbox;
  }

  /**
   * Retrieve a toolbox by its layout's asset ID.
   * @param state The ChartEditorState instance.
   * @param id The asset ID of the toolbox layout.
   * @return The toolbox.
   */
  public static function getToolbox_OLD(state:ChartEditorState, id:String):Null<CollapsibleDialog>
  {
    var toolbox:Null<CollapsibleDialog> = state.activeToolboxes.get(id);

    // Initialize the toolbox without showing it.
    if (toolbox == null) toolbox = initToolbox(state, id);

    if (toolbox == null) throw 'ChartEditorToolboxHandler.getToolbox_OLD() - Could not retrieve or build toolbox: $id';

    return toolbox;
  }

  public static function getToolbox(state:ChartEditorState, id:String):Null<ChartEditorBaseToolbox>
  {
    var toolbox:Null<CollapsibleDialog> = state.activeToolboxes.get(id);

    // Initialize the toolbox without showing it.
    if (toolbox == null) toolbox = initToolbox(state, id);

    if (toolbox == null) throw 'ChartEditorToolboxHandler.getToolbox() - Could not retrieve or build toolbox: $id';

    return cast toolbox;
  }

  static function buildToolboxNoteDataLayout(state:ChartEditorState):Null<CollapsibleDialog>
  {
    var toolbox:CollapsibleDialog = cast RuntimeComponentBuilder.fromAsset(ChartEditorState.CHART_EDITOR_TOOLBOX_NOTEDATA_LAYOUT);

    if (toolbox == null) return null;

    // Starting position.
    toolbox.x = 75;
    toolbox.y = 100;

    toolbox.onDialogClosed = function(event:DialogEvent) {
      state.menubarItemToggleToolboxNotes.selected = false;
    }

    var toolboxNotesNoteKind:Null<DropDown> = toolbox.findComponent('toolboxNotesNoteKind', DropDown);
    if (toolboxNotesNoteKind == null) throw 'ChartEditorToolboxHandler.buildToolboxNoteDataLayout() - Could not find toolboxNotesNoteKind component.';
    var toolboxNotesCustomKindLabel:Null<Label> = toolbox.findComponent('toolboxNotesCustomKindLabel', Label);
    if (toolboxNotesCustomKindLabel == null)
      throw 'ChartEditorToolboxHandler.buildToolboxNoteDataLayout() - Could not find toolboxNotesCustomKindLabel component.';
    var toolboxNotesCustomKind:Null<TextField> = toolbox.findComponent('toolboxNotesCustomKind', TextField);
    if (toolboxNotesCustomKind == null) throw 'ChartEditorToolboxHandler.buildToolboxNoteDataLayout() - Could not find toolboxNotesCustomKind component.';

    toolboxNotesNoteKind.onChange = function(event:UIEvent) {
      var isCustom:Bool = (event.data.id == '~CUSTOM~');

      if (isCustom)
      {
        toolboxNotesCustomKindLabel.hidden = false;
        toolboxNotesCustomKind.hidden = false;

        state.noteKindToPlace = toolboxNotesCustomKind.text;
      }
      else
      {
        toolboxNotesCustomKindLabel.hidden = true;
        toolboxNotesCustomKind.hidden = true;

        state.noteKindToPlace = event.data.id;
      }
    }

    toolboxNotesCustomKind.onChange = function(event:UIEvent) {
      state.noteKindToPlace = toolboxNotesCustomKind.text;
    }

    return toolbox;
  }

  static function onShowToolboxNoteData(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function onHideToolboxNoteData(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function onHideToolboxMetadata(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function onHideToolboxEventData(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function onHideToolboxDifficulty(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function onShowToolboxPlaytestProperties(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function onHideToolboxPlaytestProperties(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function buildToolboxPlaytestPropertiesLayout(state:ChartEditorState):Null<CollapsibleDialog>
  {
    // fill with playtest properties
    var toolbox:CollapsibleDialog = cast RuntimeComponentBuilder.fromAsset(ChartEditorState.CHART_EDITOR_TOOLBOX_PLAYTEST_PROPERTIES_LAYOUT);

    if (toolbox == null) return null;

    toolbox.onDialogClosed = function(_) {
      state.menubarItemToggleToolboxPlaytestProperties.selected = false;
    }

    var checkboxPracticeMode:Null<CheckBox> = toolbox.findComponent('practiceModeCheckbox', CheckBox);
    if (checkboxPracticeMode == null) throw 'ChartEditorToolboxHandler.buildToolboxPlaytestPropertiesLayout() - Could not find practiceModeCheckbox component.';

    checkboxPracticeMode.selected = state.playtestPracticeMode;

    checkboxPracticeMode.onClick = _ -> {
      state.playtestPracticeMode = checkboxPracticeMode.selected;
    };

    var checkboxStartTime:Null<CheckBox> = toolbox.findComponent('playtestStartTimeCheckbox', CheckBox);
    if (checkboxStartTime == null)
      throw 'ChartEditorToolboxHandler.buildToolboxPlaytestPropertiesLayout() - Could not find playtestStartTimeCheckbox component.';

    checkboxStartTime.selected = state.playtestStartTime;

    checkboxStartTime.onClick = _ -> {
      state.playtestStartTime = checkboxStartTime.selected;
    };

    var checkboxDebugger:Null<CheckBox> = toolbox.findComponent('playtestDebuggerCheckbox', CheckBox);

    if (checkboxDebugger == null) throw 'ChartEditorToolboxHandler.buildToolboxPlaytestPropertiesLayout() - Could not find playtestDebuggerCheckbox component.';

    state.enabledDebuggerPopup = checkboxDebugger.selected;

    checkboxDebugger.onClick = _ -> {
      state.enabledDebuggerPopup = checkboxDebugger.selected;
    };

    return toolbox;
  }

  static function buildToolboxDifficultyLayout(state:ChartEditorState):Null<CollapsibleDialog>
  {
    var toolbox:CollapsibleDialog = cast RuntimeComponentBuilder.fromAsset(ChartEditorState.CHART_EDITOR_TOOLBOX_DIFFICULTY_LAYOUT);

    if (toolbox == null) return null;

    // Starting position.
    toolbox.x = 125;
    toolbox.y = 200;

    toolbox.onDialogClosed = function(event:UIEvent) {
      state.menubarItemToggleToolboxDifficulty.selected = false;
    }

    var difficultyToolboxAddVariation:Null<Button> = toolbox.findComponent('difficultyToolboxAddVariation', Button);
    if (difficultyToolboxAddVariation == null)
      throw 'ChartEditorToolboxHandler.buildToolboxDifficultyLayout() - Could not find difficultyToolboxAddVariation component.';
    var difficultyToolboxAddDifficulty:Null<Button> = toolbox.findComponent('difficultyToolboxAddDifficulty', Button);
    if (difficultyToolboxAddDifficulty == null)
      throw 'ChartEditorToolboxHandler.buildToolboxDifficultyLayout() - Could not find difficultyToolboxAddDifficulty component.';
    var difficultyToolboxSaveMetadata:Null<Button> = toolbox.findComponent('difficultyToolboxSaveMetadata', Button);
    if (difficultyToolboxSaveMetadata == null)
      throw 'ChartEditorToolboxHandler.buildToolboxDifficultyLayout() - Could not find difficultyToolboxSaveMetadata component.';
    var difficultyToolboxSaveChart:Null<Button> = toolbox.findComponent('difficultyToolboxSaveChart', Button);
    if (difficultyToolboxSaveChart == null)
      throw 'ChartEditorToolboxHandler.buildToolboxDifficultyLayout() - Could not find difficultyToolboxSaveChart component.';
    // var difficultyToolboxSaveAll:Null<Button> = toolbox.findComponent('difficultyToolboxSaveAll', Button);
    // if (difficultyToolboxSaveAll == null) throw 'ChartEditorToolboxHandler.buildToolboxDifficultyLayout() - Could not find difficultyToolboxSaveAll component.';
    var difficultyToolboxLoadMetadata:Null<Button> = toolbox.findComponent('difficultyToolboxLoadMetadata', Button);
    if (difficultyToolboxLoadMetadata == null)
      throw 'ChartEditorToolboxHandler.buildToolboxDifficultyLayout() - Could not find difficultyToolboxLoadMetadata component.';
    var difficultyToolboxLoadChart:Null<Button> = toolbox.findComponent('difficultyToolboxLoadChart', Button);
    if (difficultyToolboxLoadChart == null)
      throw 'ChartEditorToolboxHandler.buildToolboxDifficultyLayout() - Could not find difficultyToolboxLoadChart component.';

    difficultyToolboxAddVariation.onClick = function(_:UIEvent) {
      state.openAddVariationDialog(true);
    };

    difficultyToolboxAddDifficulty.onClick = function(_:UIEvent) {
      state.openAddDifficultyDialog(true);
    };

    difficultyToolboxSaveMetadata.onClick = function(_:UIEvent) {
      var vari:String = state.selectedVariation != Constants.DEFAULT_VARIATION ? '-${state.selectedVariation}' : '';
      FileUtil.writeFileReference('${state.currentSongId}$vari-metadata.json', state.currentSongMetadata.serialize());
    };

    difficultyToolboxSaveChart.onClick = function(_:UIEvent) {
      var vari:String = state.selectedVariation != Constants.DEFAULT_VARIATION ? '-${state.selectedVariation}' : '';
      FileUtil.writeFileReference('${state.currentSongId}$vari-chart.json', state.currentSongChartData.serialize());
    };

    difficultyToolboxLoadMetadata.onClick = function(_:UIEvent) {
      // Replace metadata for current variation.
      SongSerializer.importSongMetadataAsync(function(songMetadata) {
        state.currentSongMetadata = songMetadata;
      });
    };

    difficultyToolboxLoadChart.onClick = function(_:UIEvent) {
      // Replace chart data for current variation.
      SongSerializer.importSongChartDataAsync(function(songChartData) {
        state.currentSongChartData = songChartData;
        state.noteDisplayDirty = true;
      });
    };

    state.difficultySelectDirty = true;

    return toolbox;
  }

  static function onShowToolboxDifficulty(state:ChartEditorState, toolbox:CollapsibleDialog):Void
  {
    // Update the selected difficulty when reopening the toolbox.
    var treeView:Null<TreeView> = toolbox.findComponent('difficultyToolboxTree');
    if (treeView == null) return;

    var current = state.getCurrentTreeDifficultyNode(treeView);
    if (current == null) return;
    treeView.selectedNode = current;
    trace('selected node: ${treeView.selectedNode}');
  }

  static function buildToolboxMetadataLayout(state:ChartEditorState):Null<ChartEditorBaseToolbox>
  {
    var toolbox:ChartEditorBaseToolbox = ChartEditorMetadataToolbox.build(state);

    if (toolbox == null) return null;

    return toolbox;
  }

  static function buildToolboxEventDataLayout(state:ChartEditorState):Null<ChartEditorBaseToolbox>
  {
    var toolbox:ChartEditorBaseToolbox = ChartEditorEventDataToolbox.build(state);

    if (toolbox == null) return null;

    return toolbox;
  }

  static function buildToolboxPlayerPreviewLayout(state:ChartEditorState):Null<CollapsibleDialog>
  {
    var toolbox:CollapsibleDialog = cast RuntimeComponentBuilder.fromAsset(ChartEditorState.CHART_EDITOR_TOOLBOX_PLAYER_PREVIEW_LAYOUT);

    if (toolbox == null) return null;

    // Starting position.
    toolbox.x = 200;
    toolbox.y = 350;

    toolbox.onDialogClosed = function(event:DialogEvent) {
      state.menubarItemToggleToolboxPlayerPreview.selected = false;
    }

    var charPlayer:Null<CharacterPlayer> = toolbox.findComponent('charPlayer');
    if (charPlayer == null) throw 'ChartEditorToolboxHandler.buildToolboxPlayerPreviewLayout() - Could not find charPlayer component.';
    // TODO: We need to implement character swapping in ChartEditorState.
    charPlayer.loadCharacter('bf');
    charPlayer.characterType = CharacterType.BF;
    charPlayer.flip = true;
    charPlayer.targetScale = 0.5;

    return toolbox;
  }

  static function onShowToolboxPlayerPreview(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function onHideToolboxPlayerPreview(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function buildToolboxOpponentPreviewLayout(state:ChartEditorState):Null<CollapsibleDialog>
  {
    var toolbox:CollapsibleDialog = cast RuntimeComponentBuilder.fromAsset(ChartEditorState.CHART_EDITOR_TOOLBOX_OPPONENT_PREVIEW_LAYOUT);

    if (toolbox == null) return null;

    // Starting position.
    toolbox.x = 200;
    toolbox.y = 350;

    toolbox.onDialogClosed = (event:DialogEvent) -> {
      state.menubarItemToggleToolboxOpponentPreview.selected = false;
    }

    var charPlayer:Null<CharacterPlayer> = toolbox.findComponent('charPlayer');
    if (charPlayer == null) throw 'ChartEditorToolboxHandler.buildToolboxOpponentPreviewLayout() - Could not find charPlayer component.';
    // TODO: We need to implement character swapping in ChartEditorState.
    charPlayer.loadCharacter('dad');
    charPlayer.characterType = CharacterType.DAD;
    charPlayer.flip = false;
    charPlayer.targetScale = 0.5;

    return toolbox;
  }

  static function onShowToolboxOpponentPreview(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}

  static function onHideToolboxOpponentPreview(state:ChartEditorState, toolbox:CollapsibleDialog):Void {}
}