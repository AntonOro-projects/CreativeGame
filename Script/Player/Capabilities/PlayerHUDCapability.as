/**
 * Capability that manages the player's HUD display.
 * This capability creates and manages the player HUD widget.
 */
class UPlayerHUDCapability : UBaseCapability
{
    // HUD class to instantiate
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "HUD")
    TSubclassOf<UPlayerHUD> PlayerHUDClass;

    // HUD manager instance
    UPROPERTY()
    UPlayerHUDManager HUDManager;

    // Cached references
    ABaseECSPlayerController CachedPlayerController;
    ABaseECSCharacter CachedCharacter;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive()
    {
        // Active when attached to a character with a player controller
        ABaseECSCharacter Character = Cast<ABaseECSCharacter>(GetOwner());
        if (Character != nullptr)
        {
            APlayerController PC = Cast<APlayerController>(Character.GetController());
            return PC != nullptr;
        }
        return false;
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityActivated()
    {
        // Cache references
        CachedCharacter = Cast<ABaseECSCharacter>(GetOwner());
        if (CachedCharacter != nullptr)
        {
            CachedPlayerController = Cast<ABaseECSPlayerController>(CachedCharacter.GetController());
        }

        // Create HUD manager
        if (CachedPlayerController != nullptr)
        {
            SetupHUD();
        }
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityDeactivated()
    {
        // Clean up HUD
        if (HUDManager != nullptr && HUDManager.IsValid())
        {
            // HUD will be cleaned up when the manager is destroyed
        }

        // Clear references
        HUDManager = nullptr;
        CachedPlayerController = nullptr;
        CachedCharacter = nullptr;
    }

    void SetupHUD()
    {
        if (CachedPlayerController == nullptr)
            return;

        // Get HUD class from character if not set
        if (PlayerHUDClass == nullptr)
        {
            ANormalPlayerCharacter PlayerCharacter = Cast<ANormalPlayerCharacter>(CachedCharacter);
            if (PlayerCharacter != nullptr)
            {
                PlayerHUDClass = PlayerCharacter.PlayerHUDClass;
            }
        }

        if (PlayerHUDClass != nullptr)
        {
            // Create HUD manager
            HUDManager = Cast<UPlayerHUDManager>(NewObject(this, UPlayerHUDManager));
            if (HUDManager != nullptr)
            {
                HUDManager.Initialize(CachedPlayerController, PlayerHUDClass);
                Log("Player HUD initialized successfully");
            }
            else
            {
                Log("Failed to create HUD manager");
            }
        }
        else
        {
            Log("No PlayerHUDClass assigned - you need to set this in the character blueprint!");
        }
    }

    // Public interface for other capabilities to use
    UFUNCTION(BlueprintCallable, Category = "Player HUD")
    void ShowInteractionPrompt(FString PromptText)
    {
        if (HUDManager != nullptr && HUDManager.IsValid())
        {
            HUDManager.ShowInteractionPrompt(PromptText);
        }
    }

    UFUNCTION(BlueprintCallable, Category = "Player HUD")
    void HideInteractionPrompt()
    {
        if (HUDManager != nullptr && HUDManager.IsValid())
        {
            HUDManager.HideInteractionPrompt();
        }
    }

    UFUNCTION(BlueprintCallable, Category = "Player HUD")
    void UpdateInventoryDisplay(int32 SelectedSlot, FString ItemName)
    {
        if (HUDManager != nullptr && HUDManager.IsValid())
        {
            HUDManager.UpdateInventoryDisplay(SelectedSlot, ItemName);
        }
    }

    UFUNCTION(BlueprintCallable, Category = "Player HUD")
    UPlayerHUDManager GetHUDManager() const
    {
        return HUDManager;
    }

    UFUNCTION(BlueprintOverride)
    void TickCapability(float DeltaTime)
    {
        // HUD doesn't need continuous ticking
        // All updates are event-driven
    }
};
