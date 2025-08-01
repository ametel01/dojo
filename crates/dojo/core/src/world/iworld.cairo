//! World interface.

use dojo::meta::Layout;
use dojo::model::{ModelIndex, ResourceMetadata};
use starknet::{ClassHash, ContractAddress};
use super::resource::Resource;

#[starknet::interface]
pub trait IUpgradeableWorld<T> {
    /// Upgrades the world with new_class_hash.
    ///
    /// # Arguments
    ///
    /// * `new_class_hash` - The new world class hash.
    fn upgrade(ref self: T, new_class_hash: ClassHash);
}

#[starknet::interface]
pub trait IWorld<T> {
    /// Returns the resource from its selector.
    ///
    /// # Arguments
    ///   * `selector` - the resource selector
    ///
    /// # Returns
    ///   * `Resource` - the resource data associated with the selector.
    fn resource(self: @T, selector: felt252) -> Resource;

    /// Issues an autoincremented id to the caller.
    /// This functionalities is useful to generate unique, but sequential ids.
    ///
    /// Note: This functionalities may impact performances since transaction parallelisation can't
    /// be achieved since the same storage slot is being written.
    fn uuid(ref self: T) -> usize;

    /// Returns the metadata of the resource.
    ///
    /// # Arguments
    ///
    /// `resource_selector` - The resource selector.
    fn metadata(self: @T, resource_selector: felt252) -> ResourceMetadata;

    /// Sets the metadata of the resource.
    ///
    /// # Arguments
    ///
    /// `metadata` - The metadata content for the resource.
    fn set_metadata(ref self: T, metadata: ResourceMetadata);

    /// Registers a namespace in the world.
    ///
    /// # Arguments
    ///
    /// * `namespace` - The name of the namespace to be registered.
    fn register_namespace(ref self: T, namespace: ByteArray);

    /// Registers an event in the world.
    ///
    /// # Arguments
    ///
    /// * `namespace` - The namespace of the event to be registered.
    /// * `class_hash` - The class hash of the event to be registered.
    fn register_event(ref self: T, namespace: ByteArray, class_hash: ClassHash);

    /// Registers a model in the world.
    ///
    /// # Arguments
    ///
    /// * `namespace` - The namespace of the model to be registered.
    /// * `class_hash` - The class hash of the model to be registered.
    fn register_model(ref self: T, namespace: ByteArray, class_hash: ClassHash);

    /// Registers and deploys a contract associated with the world and returns the address of newly
    /// deployed contract.
    ///
    /// # Arguments
    ///
    /// * `salt` - The salt use for contract deployment.
    /// * `namespace` - The namespace of the contract to be registered.
    /// * `class_hash` - The class hash of the contract.
    fn register_contract(
        ref self: T, salt: felt252, namespace: ByteArray, class_hash: ClassHash,
    ) -> ContractAddress;

    /// Registers an already deployed external contract.
    ///
    /// # Arguments
    ///
    /// * `namespace` - The namespace of the external contract.
    /// * `contract_name` - The Starknet contract name.
    /// * `instance_name` - A name given to this instance of `contract_name`.
    /// * `contract_address` - The address of the deployed contract.
    /// * `block_number` - The block number to use to start contract indexing.
    fn register_external_contract(
        ref self: T,
        namespace: ByteArray,
        contract_name: ByteArray,
        instance_name: ByteArray,
        contract_address: ContractAddress,
        block_number: u64,
    );

    /// Registers and declare a library associated with the world and returns the class_hash of
    /// newly declared library.
    ///
    /// # Arguments
    ///
    /// * `namespace` - The namespace of the contract to be registered.
    /// * `class_hash` - The class hash of the library.
    /// * `name` - The name of the library.
    /// * `version` - The version of the library.
    fn register_library(
        ref self: T,
        namespace: ByteArray,
        class_hash: ClassHash,
        name: ByteArray,
        version: ByteArray,
    ) -> ClassHash;

    /// Initializes a contract associated registered in the world.
    ///
    /// As a constructor call, the initialization function can be called only once, and only
    /// callable by the world itself.
    ///
    /// Also, the caller of this function must have the writer owner permission for the contract
    /// resource.
    fn init_contract(ref self: T, selector: felt252, init_calldata: Span<felt252>);

    /// Upgrades an event in the world.
    ///
    /// # Arguments
    ///
    /// * `namespace` - The namespace of the event to be upgraded.
    /// * `class_hash` - The class hash of the event to be upgraded.
    fn upgrade_event(ref self: T, namespace: ByteArray, class_hash: ClassHash);

    /// Upgrades a model in the world.
    ///
    /// # Arguments
    ///
    /// * `namespace` - The namespace of the model to be upgraded.
    /// * `class_hash` - The class hash of the model to be upgraded.
    fn upgrade_model(ref self: T, namespace: ByteArray, class_hash: ClassHash);

    /// Upgrades an already deployed contract associated with the world and returns the new class
    /// hash.
    ///
    /// # Arguments
    ///
    /// * `namespace` - The namespace of the contract to be upgraded.
    /// * `class_hash` - The class hash of the contract.
    fn upgrade_contract(ref self: T, namespace: ByteArray, class_hash: ClassHash) -> ClassHash;

    /// Upgrades an already registered external contract with a new address.
    ///
    /// # Arguments

    /// * `namespace` - The namespace of the external contract.
    /// * `instance_name` - The contract instance name.
    /// * `contract_address` - The new address of the deployed contract.
    /// * `block_number` - The block number to use to start contract indexing.
    fn upgrade_external_contract(
        ref self: T,
        namespace: ByteArray,
        instance_name: ByteArray,
        contract_address: ContractAddress,
        block_number: u64,
    );

    /// Emits a custom event that was previously registered in the world.
    /// The dojo event emission is permissioned, since data are collected by
    /// Torii and served to clients.
    ///
    /// # Arguments
    ///
    /// * `event_selector` - The selector of the event.
    /// * `keys` - The keys of the event.
    /// * `values` - The data to be logged by the event.
    fn emit_event(ref self: T, event_selector: felt252, keys: Span<felt252>, values: Span<felt252>);

    /// Emits multiple events.
    /// Permissions are only checked once, then the events are batched.
    ///
    /// # Arguments
    ///
    /// * `event_selector` - The selector of the event.
    /// * `keys` - The keys of the event.
    /// * `values` - The data to be logged by the event.
    fn emit_events(
        ref self: T,
        event_selector: felt252,
        keys: Span<Span<felt252>>,
        values: Span<Span<felt252>>,
    );

    /// Gets the values of a model entity/member.
    /// Returns a zero initialized model value if the entity/member has not been set.
    ///
    /// # Arguments
    ///
    /// * `model_selector` - The selector of the model to be retrieved.
    /// * `index` - The index of the entity/member to read.
    /// * `layout` - The memory layout of the model.
    ///
    /// # Returns
    ///
    /// * `Span<felt252>` - The serialized value of the model, zero initialized if not set.
    fn entity(
        self: @T, model_selector: felt252, index: ModelIndex, layout: Layout,
    ) -> Span<felt252>;

    /// Gets the model values for the given entities.
    ///
    /// # Arguments
    ///
    /// * `model_selector` - The selector of the model to be retrieved.
    /// * `indices` - The indexes of the entities/members to read.
    /// * `layout` - The memory layout of the model.
    fn entities(
        self: @T, model_selector: felt252, indexes: Span<ModelIndex>, layout: Layout,
    ) -> Span<Span<felt252>>;

    /// Sets the model value for the given entity/member.
    ///
    /// # Arguments
    ///
    /// * `model_selector` - The selector of the model to be set.
    /// * `index` - The index of the entity/member to write.
    /// * `values` - The value to be set, serialized using the model layout format.
    /// * `layout` - The memory layout of the model.
    fn set_entity(
        ref self: T,
        model_selector: felt252,
        index: ModelIndex,
        values: Span<felt252>,
        layout: Layout,
    );

    /// Sets the model values for the given entities.
    /// The permissions are only checked once, then the writes are batched.
    ///
    /// # Arguments
    ///
    /// * `model_selector` - The selector of the model to be set.
    /// * `indexes` - The indexes of the entities/members to write.
    /// * `values` - The values to be set, serialized using the model layout format.
    /// * `layout` - The memory layout of the model.
    fn set_entities(
        ref self: T,
        model_selector: felt252,
        indexes: Span<ModelIndex>,
        values: Span<Span<felt252>>,
        layout: Layout,
    );

    /// Deletes a model value for the given entity/member.
    /// Deleting is setting all the values to 0 in the given layout.
    ///
    /// # Arguments
    ///
    /// * `model_selector` - The selector of the model to be deleted.
    /// * `index` - The index of the entity/member to delete.
    /// * `layout` - The memory layout of the model.
    fn delete_entity(ref self: T, model_selector: felt252, index: ModelIndex, layout: Layout);

    /// Deletes the model values for the given entities.
    /// The permissions are only checked once, then the deletes are batched.
    ///
    /// # Arguments
    ///
    /// * `model_selector` - The selector of the model to be deleted.
    /// * `indexes` - The indexes of the entities/members to delete.
    /// * `layout` - The memory layout of the model.
    fn delete_entities(
        ref self: T, model_selector: felt252, indexes: Span<ModelIndex>, layout: Layout,
    );

    /// Returns true if the provided account has owner permission for the resource, false otherwise.
    ///
    /// # Arguments
    ///
    /// * `resource` - The selector of the resource.
    /// * `address` - The address of the contract.
    fn is_owner(self: @T, resource: felt252, address: ContractAddress) -> bool;

    /// Grants owner permission to the address.
    /// Can only be called by an existing owner or the world admin.
    ///
    /// Note that this resource must have been registered to the world first.
    ///
    /// # Arguments
    ///
    /// * `resource` - The selector of the resource.
    /// * `address` - The address of the contract to grant owner permission to.
    fn grant_owner(ref self: T, resource: felt252, address: ContractAddress);

    /// Revokes owner permission to the contract for the resource.
    /// Can only be called by an existing owner or the world admin.
    ///
    /// Note that this resource must have been registered to the world first.
    ///
    /// # Arguments
    ///
    /// * `resource` - The selector of the resource.
    /// * `address` - The address of the contract to revoke owner permission from.
    fn revoke_owner(ref self: T, resource: felt252, address: ContractAddress);


    /// Get the number of owners for a resource.
    ///
    /// # Arguments
    ///   * `resource` - The selector of the resource.
    fn owners_count(self: @T, resource: felt252) -> u64;

    /// Returns true if the provided contract has writer permission for the resource, false
    /// otherwise.
    ///
    /// # Arguments
    ///
    /// * `resource` - The selector of the resource.
    /// * `contract` - The address of the contract.
    fn is_writer(self: @T, resource: felt252, contract: ContractAddress) -> bool;

    /// Grants writer permission to the contract for the resource.
    /// Can only be called by an existing resource owner or the world admin.
    ///
    /// Note that this resource must have been registered to the world first.
    ///
    /// # Arguments
    ///
    /// * `resource` - The selector of the resource.
    /// * `contract` - The address of the contract to grant writer permission to.
    fn grant_writer(ref self: T, resource: felt252, contract: ContractAddress);

    /// Revokes writer permission to the contract for the resource.
    /// Can only be called by an existing resource owner or the world admin.
    ///
    /// Note that this resource must have been registered to the world first.
    ///
    /// # Arguments
    ///
    /// * `resource` - The selector of the resource.
    /// * `contract` - The address of the contract to revoke writer permission from.
    fn revoke_writer(ref self: T, resource: felt252, contract: ContractAddress);
}

#[starknet::interface]
#[cfg(target: "test")]
pub trait IWorldTest<T> {
    /// Sets the model value for the given entity/member without checking for resource permissions.
    fn set_entity_test(
        ref self: T,
        model_selector: felt252,
        index: ModelIndex,
        values: Span<felt252>,
        layout: Layout,
    );

    /// Deletes a model value for the given entity/member without checking for resource permissions.
    fn delete_entity_test(ref self: T, model_selector: felt252, index: ModelIndex, layout: Layout);

    /// Emits a custom event that was previously registered in the world without checking for
    /// resource permissions.
    fn emit_event_test(
        ref self: T, event_selector: felt252, keys: Span<felt252>, values: Span<felt252>,
    );

    /// Returns the address of a registered contract, panics otherwise.
    fn dojo_contract_address(self: @T, contract_selector: felt252) -> ContractAddress;
}
