/**
 * Data asset that represents an inventory item with mesh and UI support.
 * This contains all the data needed to display and use an item in the inventory.
 */
class UInventoryItemData : UDataAsset
{
    // Display information
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Info")
    FString ItemName = "Unnamed Item";

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Info", meta = (MultiLine = true))
    FString Description = "No description available.";

    // Visual representation
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Visuals")
    UStaticMesh ItemMesh;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Visuals")
    UMaterialInterface ItemMaterial;

    // UI representation
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item UI")
    UTexture2D ItemIcon;

    // Item properties
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Properties")
    bool bIsStackable = false;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Properties", meta = (EditCondition = "bIsStackable"))
    int32 MaxStackSize = 1;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Properties")
    float ItemWeight = 1.0f;

    // Rarity/Quality
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Properties")
    FLinearColor ItemRarityColor = FLinearColor::White;

    // Item category for organization
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Properties")
    FString ItemCategory = "General";

    // Transform settings for when item is held/displayed
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Transform")
    FVector HeldItemOffset = FVector::ZeroVector;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Transform")
    FRotator HeldItemRotation = FRotator::ZeroRotator;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Item Transform")
    FVector HeldItemScale = FVector::OneVector;

    // Utility functions
    UFUNCTION(BlueprintPure, Category = "Item Info")
    FString GetDisplayName() const
    {
        return ItemName.IsEmpty() ? "Unnamed Item" : ItemName;
    }

    UFUNCTION(BlueprintPure, Category = "Item Info")
    FString GetDisplayDescription() const
    {
        return Description.IsEmpty() ? "No description available." : Description;
    }

    UFUNCTION(BlueprintPure, Category = "Item Visuals")
    bool HasValidMesh() const
    {
        return ItemMesh != nullptr;
    }

    UFUNCTION(BlueprintPure, Category = "Item UI")
    bool HasValidIcon() const
    {
        return ItemIcon != nullptr;
    }

    UFUNCTION(BlueprintPure, Category = "Item Transform")
    FTransform GetHeldItemTransform() const
    {
        return FTransform(HeldItemRotation, HeldItemOffset, HeldItemScale);
    }
};
