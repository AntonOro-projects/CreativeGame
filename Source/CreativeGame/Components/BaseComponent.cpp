#include "BaseComponent.h"

UBaseComponent::UBaseComponent()
{
	// Components should NEVER tick - they are pure data containers
	PrimaryComponentTick.bCanEverTick = false;
	PrimaryComponentTick.bStartWithTickEnabled = false;
	
	// Disable editor ticking as well
	bTickInEditor = false;
}

void UBaseComponent::BeginPlay()
{
	Super::BeginPlay();
	
	// Ensure we never accidentally start ticking
	SetComponentTickEnabled(false);
}
