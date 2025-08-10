// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseECSGameMode.h"
#include "ECSPawnInterface.h"
#include "Engine/World.h"
#include "Engine/NetConnection.h"
#include "Kismet/GameplayStatics.h"
#include "GameFramework/PlayerController.h"

ABaseECSGameMode::ABaseECSGameMode()
{
	// Set default ECS classes
	PlayerControllerClass = ABaseECSPlayerController::StaticClass();
	DefaultPawnClass = ABaseECSCharacter::StaticClass();
	
	// Set our preferred ECS classes (can be overridden in Blueprint)
	ECSPlayerControllerClass = ABaseECSPlayerController::StaticClass();
	ECSCharacterClass = ABaseECSCharacter::StaticClass();
	ECSPawnClass = ABaseECSPawn::StaticClass();
}

void ABaseECSGameMode::BeginPlay()
{
	Super::BeginPlay();
	
	// Fix any existing non-ECS objects in the level
	FixExistingPlayerControllers();
	FixExistingPawns();
}

APawn* ABaseECSGameMode::SpawnDefaultPawnAtTransform_Implementation(AController* NewPlayer, const FTransform& SpawnTransform)
{
	// Ensure we only spawn ECS pawns (including characters)
	UClass* PawnClassToSpawn = DefaultPawnClass;
	
	// Check if the default pawn class is ECS-enabled using our interface
	bool bIsECSClass = false;
	if (PawnClassToSpawn)
	{
		// Check if it implements our ECS interface (works for both Pawns and Characters)
		bIsECSClass = PawnClassToSpawn->ImplementsInterface(UECSPawnInterface::StaticClass());
	}
	
	// If not ECS-enabled, use our preferred ECS character class
	if (!bIsECSClass)
	{
		PawnClassToSpawn = ECSCharacterClass ? ECSCharacterClass.Get() : ABaseECSCharacter::StaticClass();
	}
	
	if (UWorld* World = GetWorld())
	{
		APawn* SpawnedPawn = World->SpawnActor<APawn>(PawnClassToSpawn, SpawnTransform);
		
		// Ensure it implements our ECS interface (works for both Pawns and Characters)
		if (IECSPawnInterface* ECSInterface = Cast<IECSPawnInterface>(SpawnedPawn))
		{
			return SpawnedPawn;
		}
		
		// If somehow we failed to spawn an ECS pawn, destroy it and spawn a character
		if (SpawnedPawn)
		{
			SpawnedPawn->Destroy();
			UE_LOG(LogTemp, Error, TEXT("Failed to spawn ECS-enabled pawn class %s. Falling back to ABaseECSCharacter."), 
				*PawnClassToSpawn->GetName());
		}
		
		return World->SpawnActor<ABaseECSCharacter>(ECSCharacterClass ? ECSCharacterClass.Get() : ABaseECSCharacter::StaticClass(), SpawnTransform);
	}
	
	return nullptr;
}

ABaseECSPlayerController* ABaseECSGameMode::EnsureECSPlayerController(AController* Controller)
{
	// If it's already an ECS controller, return it
	if (ABaseECSPlayerController* ECSController = Cast<ABaseECSPlayerController>(Controller))
	{
		return ECSController;
	}
	
	// If it's a regular PlayerController, we need to replace it
	if (APlayerController* PC = Cast<APlayerController>(Controller))
	{
		if (UWorld* World = GetWorld())
		{
			// Store the possessed pawn
			APawn* PossessedPawn = PC->GetPawn();
			
			// Unpossess first
			if (PossessedPawn)
			{
				PC->UnPossess();
			}
			
			// Spawn new ECS Player Controller
			FActorSpawnParameters SpawnParams;
			SpawnParams.Owner = nullptr;
			
			ABaseECSPlayerController* NewECSController = World->SpawnActor<ABaseECSPlayerController>(
				ECSPlayerControllerClass ? ECSPlayerControllerClass.Get() : ABaseECSPlayerController::StaticClass(),
				SpawnParams
			);
			
			if (NewECSController)
			{
				// Transfer ownership/properties if needed
				NewECSController->SetPlayer(PC->GetNetOwningPlayer());
				
				// Re-possess the pawn with the new ECS controller
				if (PossessedPawn)
				{
					NewECSController->Possess(PossessedPawn);
				}
				
				// Destroy the old controller
				PC->Destroy();
				
				return NewECSController;
			}
		}
	}
	
	return nullptr;
}

APawn* ABaseECSGameMode::EnsureECSPawn(APawn* Pawn)
{
	// Check if it's already an ECS-enabled pawn using our interface
	if (IECSPawnInterface* ECSInterface = Cast<IECSPawnInterface>(Pawn))
	{
		return Pawn; // Return the pawn itself, not just a cast to ABaseECSPawn
	}
	
	// If it's a non-ECS pawn, we might need to replace it
	if (Pawn)
	{
		UE_LOG(LogTemp, Warning, TEXT("Found non-ECS Pawn: %s (Class: %s). Consider replacing with ABaseECSCharacter or ABaseECSPawn."), 
			*Pawn->GetName(), *Pawn->GetClass()->GetName());
		
		// Optionally, you could automatically replace it here, but that might be too aggressive
		// This function serves more as a validation/warning system
	}
	
	return nullptr;
}

void ABaseECSGameMode::FixExistingPlayerControllers()
{
	if (UWorld* World = GetWorld())
	{
		// Find all existing player controllers and ensure they're ECS
		for (FConstPlayerControllerIterator Iterator = World->GetPlayerControllerIterator(); Iterator; ++Iterator)
		{
			if (APlayerController* PC = Iterator->Get())
			{
				if (!Cast<ABaseECSPlayerController>(PC))
				{
					UE_LOG(LogTemp, Warning, TEXT("Found non-ECS PlayerController: %s. Replacing with ABaseECSPlayerController."), *PC->GetName());
					EnsureECSPlayerController(PC);
				}
			}
		}
	}
}

void ABaseECSGameMode::FixExistingPawns()
{
	if (UWorld* World = GetWorld())
	{
		// Find all pawns with auto-possess settings and validate they're ECS
		TArray<AActor*> AllPawns;
		UGameplayStatics::GetAllActorsOfClass(World, APawn::StaticClass(), AllPawns);
		
		for (AActor* Actor : AllPawns)
		{
			if (APawn* Pawn = Cast<APawn>(Actor))
			{
				// Check if this pawn has auto-possess enabled
				if (Pawn->AutoPossessPlayer != EAutoReceiveInput::Disabled)
				{
					// Use the ECS interface to check if it's an ECS pawn
					IECSPawnInterface* ECSPawnInterface = Cast<IECSPawnInterface>(Pawn);
					
					if (!ECSPawnInterface)
					{
						UE_LOG(LogTemp, Warning, TEXT("Found non-ECS Pawn with auto-possess: %s (Class: %s). Consider changing to ABaseECSCharacter or ABaseECSPawn."), 
							*Pawn->GetName(), *Pawn->GetClass()->GetName());
					}
					else
					{
						// Log success for debugging
						const char* TypeName = Cast<ABaseECSCharacter>(Pawn) ? "ECS Character" : "ECS Pawn";
						UE_LOG(LogTemp, Log, TEXT("Found valid ECS Pawn: %s (Class: %s) - %hs"), 
							*Pawn->GetName(), 
							*Pawn->GetClass()->GetName(),
							TypeName);
					}
				}
			}
		}
	}
}