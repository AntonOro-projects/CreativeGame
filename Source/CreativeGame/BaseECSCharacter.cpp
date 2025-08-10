// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseECSCharacter.h"
#include "BaseECSPlayerController.h"
#include "BaseECSActor.h"  // Updated include path
#include "BaseECSPawn.h"
#include "Components/InputComponent.h"
#include "Engine/World.h"
#include "Kismet/GameplayStatics.h"
#include "GameFramework/PlayerController.h"

ABaseECSCharacter::ABaseECSCharacter()
{
	PrimaryActorTick.bCanEverTick = true;
	
	// Create the capability manager component
	CapabilityManager = CreateDefaultSubobject<UCapabilityManagerComponent>(TEXT("CapabilityManager"));
	
	// Disable auto-ticking on the component since we'll manually tick it
	if (CapabilityManager)
	{
		CapabilityManager->SetComponentTickEnabled(false);
	}

	// Set default ECS controller class
	ECSControllerClass = ABaseECSPlayerController::StaticClass();
	bAutoCorrectControllers = true;
}

void ABaseECSCharacter::BeginPlay()
{
	Super::BeginPlay();
	
	// Initialize capabilities through the manager
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}

	// Check if we have a non-ECS controller and fix it if needed
	if (bAutoCorrectControllers && GetController() && !Cast<ABaseECSPlayerController>(GetController()))
	{
		UE_LOG(LogTemp, Warning, TEXT("BaseECSCharacter %s has non-ECS controller %s. Auto-correcting..."), 
			*GetName(), *GetController()->GetName());
		
		CreateECSControllerReplacement(GetController());
	}
}

void ABaseECSCharacter::PossessedBy(AController* NewController)
{
	// If auto-correction is enabled and this isn't an ECS controller
	if (bAutoCorrectControllers && NewController && !Cast<ABaseECSPlayerController>(NewController))
	{
		UE_LOG(LogTemp, Warning, TEXT("BaseECSCharacter %s being possessed by non-ECS controller %s. Creating ECS replacement..."), 
			*GetName(), *NewController->GetName());
		
		// Create ECS replacement before the possession
		if (ABaseECSPlayerController* ECSController = CreateECSControllerReplacement(NewController))
		{
			// The replacement controller will handle the possession
			return;
		}
	}
	
	// Normal possession (should be ECS controller at this point)
	Super::PossessedBy(NewController);
}

void ABaseECSCharacter::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	// Manual tick capabilities if enabled
	if (bManualCapabilityTicking && CapabilityManager)
	{
		CapabilityManager->ManualTick(DeltaTime);
	}
}

void ABaseECSCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	// Add character-specific input bindings here
	// Individual capabilities can also bind to input if needed
}

ABaseECSPlayerController* ABaseECSCharacter::GetECSController() const
{
	// Cast the controller to our ECS type - should always work if using ECS ecosystem correctly
	ABaseECSPlayerController* ECSController = Cast<ABaseECSPlayerController>(GetController());
	
	// Debug warning if we somehow have a non-ECS controller
	if (GetController() && !ECSController)
	{
		UE_LOG(LogTemp, Warning, TEXT("BaseECSCharacter %s has non-ECS controller %s! Consider using BaseECSGameMode or enabling bAutoCorrectControllers."), 
			*GetName(), *GetController()->GetName());
	}
	
	return ECSController;
}

ABaseECSPlayerController* ABaseECSCharacter::CreateECSControllerReplacement(AController* NonECSController)
{
	if (!NonECSController || !ECSControllerClass)
	{
		return nullptr;
	}

	UWorld* World = GetWorld();
	if (!World)
	{
		return nullptr;
	}

	// Store player information if it's a PlayerController
	UPlayer* Player = nullptr;
	if (APlayerController* PC = Cast<APlayerController>(NonECSController))
	{
		Player = PC->GetNetOwningPlayer();
	}

	// Unpossess this pawn from the old controller
	if (GetController() == NonECSController)
	{
		NonECSController->UnPossess();
	}

	// Create new ECS controller
	FActorSpawnParameters SpawnParams;
	SpawnParams.Owner = nullptr;
	SpawnParams.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;

	ABaseECSPlayerController* NewECSController = World->SpawnActor<ABaseECSPlayerController>(ECSControllerClass, SpawnParams);
	
	if (NewECSController)
	{
		// Transfer player ownership if applicable
		if (Player)
		{
			NewECSController->SetPlayer(Player);
		}

		// Possess this pawn with the new ECS controller
		NewECSController->Possess(this);

		// Destroy the old controller
		NonECSController->Destroy();

		UE_LOG(LogTemp, Log, TEXT("Successfully replaced non-ECS controller with ECS controller for character %s"), *GetName());
		
		return NewECSController;
	}

	UE_LOG(LogTemp, Error, TEXT("Failed to create ECS controller replacement for character %s"), *GetName());
	return nullptr;
}

TArray<ABaseECSActor*> ABaseECSCharacter::GetNearbyECSActors(float Radius) const
{
	TArray<ABaseECSActor*> NearbyECSActors;
	
	if (UWorld* World = GetWorld())
	{
		// Get all actors within radius
		TArray<AActor*> AllActors;
		UGameplayStatics::GetAllActorsOfClass(World, ABaseECSActor::StaticClass(), AllActors);
		
		const FVector MyLocation = GetActorLocation();
		
		for (AActor* Actor : AllActors)
		{
			if (Actor != this && FVector::Dist(Actor->GetActorLocation(), MyLocation) <= Radius)
			{
				if (ABaseECSActor* ECSActor = Cast<ABaseECSActor>(Actor))
				{
					NearbyECSActors.Add(ECSActor);
				}
			}
		}
	}
	
	return NearbyECSActors;
}

TArray<ABaseECSPawn*> ABaseECSCharacter::GetNearbyECSPawns(float Radius) const
{
	TArray<ABaseECSPawn*> NearbyECSPawns;
	
	if (UWorld* World = GetWorld())
	{
		// Get all pawns within radius
		TArray<AActor*> AllPawns;
		UGameplayStatics::GetAllActorsOfClass(World, ABaseECSPawn::StaticClass(), AllPawns);
		
		const FVector MyLocation = GetActorLocation();
		
		for (AActor* Actor : AllPawns)
		{
			if (Actor != this && FVector::Dist(Actor->GetActorLocation(), MyLocation) <= Radius)
			{
				if (ABaseECSPawn* ECSPawn = Cast<ABaseECSPawn>(Actor))
				{
					NearbyECSPawns.Add(ECSPawn);
				}
			}
		}
	}
	
	return NearbyECSPawns;
}

TArray<ABaseECSCharacter*> ABaseECSCharacter::GetNearbyECSCharacters(float Radius) const
{
	TArray<ABaseECSCharacter*> NearbyECSCharacters;
	
	if (UWorld* World = GetWorld())
	{
		// Get all characters within radius
		TArray<AActor*> AllCharacters;
		UGameplayStatics::GetAllActorsOfClass(World, ABaseECSCharacter::StaticClass(), AllCharacters);
		
		const FVector MyLocation = GetActorLocation();
		
		for (AActor* Actor : AllCharacters)
		{
			if (Actor != this && FVector::Dist(Actor->GetActorLocation(), MyLocation) <= Radius)
			{
				if (ABaseECSCharacter* ECSCharacter = Cast<ABaseECSCharacter>(Actor))
				{
					NearbyECSCharacters.Add(ECSCharacter);
				}
			}
		}
	}
	
	return NearbyECSCharacters;
}