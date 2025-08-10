class UPlayerHUD : UUserWidget
{
    UPROPERTY(BindWidget)
    UTextBlock InteractionText;

    UPROPERTY(BindWidget, meta = (BindWidgetOptional = "true"))
    UTextBlock InventorySlotText;

    UPROPERTY(BindWidget, meta = (BindWidgetOptional = "true"))
    UTextBlock ItemNameText;

    UFUNCTION(BlueprintCallable, Category = "Player HUD")
    void SetInteractionText(FString Text)
    {
        if (InteractionText != nullptr)
        {
            InteractionText.SetText(FText::FromString(Text));
            InteractionText.SetVisibility(Text.IsEmpty() ? ESlateVisibility::Collapsed : ESlateVisibility::Visible);
        }
    }

    UFUNCTION(BlueprintCallable, Category = "Player HUD")
    void HideInteractionText()
    {
        if (InteractionText != nullptr)
        {
            InteractionText.SetVisibility(ESlateVisibility::Collapsed);
        }
    }

    UFUNCTION(BlueprintCallable, Category = "Player HUD")
    void SetInventoryInfo(int32 SelectedSlot, FString ItemName)
    {
        if (InventorySlotText != nullptr)
        {
            InventorySlotText.SetText(FText::FromString(f"Slot {SelectedSlot}"));
        }

        if (ItemNameText != nullptr)
        {
            if (ItemName.IsEmpty())
            {
                ItemNameText.SetText(FText::FromString("Empty"));
                ItemNameText.SetVisibility(ESlateVisibility::Collapsed);
            }
            else
            {
                ItemNameText.SetText(FText::FromString(ItemName));
                ItemNameText.SetVisibility(ESlateVisibility::Visible);
            }
        }
    }
};

/**
 * Manager class for handling player HUD functionality.
 * This should be created and managed by the player controller or a HUD capability.
 */
class UPlayerHUDManager : UObject
{
    UPROPERTY()
    UPlayerHUD CachedHUD;

    UPROPERTY()
    APlayerController OwningPlayerController;

    UPROPERTY()
    TSubclassOf<UPlayerHUD> HUDClass;

    UFUNCTION(BlueprintCallable, Category = "HUD Manager")
    void Initialize(APlayerController PlayerController, TSubclassOf<UPlayerHUD> InHUDClass)
    {
        OwningPlayerController = PlayerController;
        HUDClass = InHUDClass;
        CreateHUD();
    }

    void CreateHUD()
    {
        if (OwningPlayerController != nullptr && HUDClass != nullptr)
        {
            CachedHUD = Cast<UPlayerHUD>(WidgetBlueprint::CreateWidget(HUDClass, OwningPlayerController));
            if (CachedHUD != nullptr)
            {
                CachedHUD.AddToViewport();
            }
        }
    }

    UFUNCTION(BlueprintCallable, Category = "HUD Manager")
    void ShowInteractionPrompt(FString Text)
    {
        if (CachedHUD != nullptr)
        {
            CachedHUD.SetInteractionText(Text);
        }
    }

    UFUNCTION(BlueprintCallable, Category = "HUD Manager")
    void HideInteractionPrompt()
    {
        if (CachedHUD != nullptr)
        {
            CachedHUD.HideInteractionText();
        }
    }

    UFUNCTION(BlueprintCallable, Category = "HUD Manager")
    void UpdateInventoryDisplay(int32 SelectedSlot, FString ItemName)
    {
        if (CachedHUD != nullptr)
        {
            CachedHUD.SetInventoryInfo(SelectedSlot, ItemName);
        }
    }

    UFUNCTION(BlueprintCallable, Category = "HUD Manager")
    bool IsValid() const
    {
        return CachedHUD != nullptr && OwningPlayerController != nullptr;
    }
};

// Legacy function for backward compatibility
UFUNCTION(Category = "Player HUD")
void ShowInteractionText(ABaseECSPlayerController OwningPlayer, TSubclassOf<UPlayerHUD> PlayerHUDClass, FString Text)
{
    UPlayerHUD PlayerHUD = Cast<UPlayerHUD>(WidgetBlueprint::CreateWidget(PlayerHUDClass, OwningPlayer));
    if (PlayerHUD != nullptr)
    {
        PlayerHUD.SetInteractionText(Text);
        PlayerHUD.AddToViewport();
    }
}