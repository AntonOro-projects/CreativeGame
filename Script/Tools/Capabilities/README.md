# Interactive Item System

This system allows inventory items to have interactive capabilities when held by the player. It consists of two main components:

## 1. HeldItemManagerCapability

A capability that monitors what item the player is currently holding and automatically adds/removes capabilities based on the held item's configuration.

### How it works:
- Constantly monitors the player's primary held item
- When the held item changes, it removes the old item's capability and adds the new item's capability
- Capabilities are added to the player character, not the item data itself

## 2. InteractiveItemCapability

A base capability that provides left and right mouse button input handling for held items.

### Features:
- **Activation**: Automatically active when added by the HeldItemManagerCapability
- **Input Binding**: Sets up Enhanced Input bindings for left and right mouse buttons
- **Event Handling**: Provides separate handlers for button press and release events
- **Item Context**: Has access to the currently held item data

## Setup Instructions

### 1. Configure Item Data
In your `UInventoryItemData` assets, set the `HeldItemCapability` field to the capability class you want to activate when holding this item:

```angelscript
// In Blueprint or data asset editor
HeldItemCapability = UInteractiveItemCapability::StaticClass();
```

### 2. Player Setup
The `UHeldItemManagerCapability` is automatically added to player characters. No additional setup required.

### 3. Configure Input Actions
For `UInteractiveItemCapability` or derived classes:
- Create Input Actions for `LeftMouseAction` and `RightMouseAction`
- Create an Input Mapping Context `InteractiveItemInputContext`
- Map mouse buttons to these actions in the context

### 4. Create Custom Interactive Capabilities
Extend `UInteractiveItemCapability` for specific item behaviors:

```angelscript
class UMyToolCapability : UInteractiveItemCapability
{
    void HandleLeftClick(FInputActionValue ActionValue) override
    {
        UInventoryItemData CurrentItem = GetCurrentlyHeldItem();
        if (CurrentItem != nullptr)
        {
            // Implement tool-specific left click behavior
            Print("Using tool: " + CurrentItem.GetDisplayName());
        }
    }

    void HandleRightClick(FInputActionValue ActionValue) override
    {
        // Implement tool-specific right click behavior
        Print("Secondary action for current tool");
    }
}
```

## Example Workflow

1. **Create a tool item data asset**:
   - Set `HeldItemCapability` to your custom capability class

2. **Player picks up the item**:
   - Item goes into inventory as `UInventoryItemData`

3. **Player selects the item**:
   - `HeldItemManagerCapability` detects the change
   - Removes old capability (if any)
   - Adds the tool's capability to the player

4. **Player uses mouse buttons**:
   - Input is captured by the tool's capability
   - Custom behavior executes based on the held item

## Input Action Configuration

In your Input Mapping Context, map:
- Left Mouse Button → LeftMouseAction  
- Right Mouse Button → RightMouseAction

The capability uses mapping context priority 3 to ensure it takes precedence when items are active.

## Architecture Benefits

- **Data-Driven**: Item behavior is configured in data assets
- **Automatic Management**: No manual capability management required
- **Clean Separation**: Item data remains pure data, behavior is in capabilities
- **Extensible**: Easy to create new interactive item types
