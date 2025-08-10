// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "BaseECSPlayerController.h"
#include "BaseECSCharacter.h"
#include "BaseECSPawn.h"

#include "BaseECSGameMode.generated.h"

/**
 * Base ECS Game Mode that ensures all spawned classes are ECS-enabled.
 * This Game Mode guarantees that:
 * - Player Controllers are always ABaseECSPlayerController
 * - Default Pawns are always ECS-enabled (ABaseECSCharacter or ABaseECSPawn)
 * - Any spawned players automatically get the correct ECS classes
 */
UCLASS(BlueprintType, Blueprintable)
class CREATIVEGAME_API ABaseECSGameMode : public AGameModeBase
{
	GENERATED_BODY()

public:
	ABaseECSGameMode();

	// Override to ensure spawned pawns are ECS-enabled
	virtual APawn* SpawnDefaultPawnAtTransform_Implementation(AController* NewPlayer, const FTransform& SpawnTransform) override;

	// Helper to get or create ECS Player Controller for any controller
	UFUNCTION(BlueprintCallable, Category = "ECS")
	ABaseECSPlayerController* EnsureECSPlayerController(AController* Controller);

	// Helper to validate ECS pawns (returns the pawn if it's ECS-enabled, nullptr otherwise)
	UFUNCTION(BlueprintCallable, Category = "ECS")
	APawn* EnsureECSPawn(APawn* Pawn);

protected:
	// Override these in Blueprint or derived classes to specify your exact ECS classes
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS Classes")
	TSubclassOf<ABaseECSPlayerController> ECSPlayerControllerClass;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS Classes") 
	TSubclassOf<ABaseECSCharacter> ECSCharacterClass;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS Classes")
	TSubclassOf<ABaseECSPawn> ECSPawnClass;

	// Called during BeginPlay to fix any existing non-ECS controllers/pawns in the level
	virtual void BeginPlay() override;

	// Fix any existing player controllers that aren't ECS
	UFUNCTION(BlueprintCallable, Category = "ECS")
	void FixExistingPlayerControllers();

	// Fix any existing pawns that aren't ECS (if they have auto-possess set)
	UFUNCTION(BlueprintCallable, Category = "ECS")
	void FixExistingPawns();
};