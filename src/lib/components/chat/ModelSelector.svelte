<script lang="ts">
	import { models, showSettings, settings, user, mobile, config } from '$lib/stores';
	import { onMount, tick, getContext } from 'svelte';
	import { toast } from 'svelte-sonner';
	import Selector from './ModelSelector/Selector.svelte';
	import Tooltip from '../common/Tooltip.svelte';

	import { updateUserSettings } from '$lib/apis/users';
	const i18n = getContext('i18n');

	export let selectedModels = [];
	export let disabled = false;

	export let showSetDefault = true;

	let items = [];

	const saveDefaultModel = async () => {
		const hasEmptyModel = selectedModels.filter((it) => it === '');
		if (hasEmptyModel.length) {
			toast.error($i18n.t('Choose a model before saving...'));
			return;
		}
		settings.set({ ...$settings, models: selectedModels });
		await updateUserSettings(localStorage.token, { ui: $settings });

		toast.success($i18n.t('Default model updated'));
	};

	const pinModelHandler = async (modelId) => {
		let pinnedModels = $settings?.pinnedModels ?? [];

		if (pinnedModels.includes(modelId)) {
			pinnedModels = pinnedModels.filter((id) => id !== modelId);
		} else {
			pinnedModels = [...new Set([...pinnedModels, modelId])];
		}

		settings.set({ ...$settings, pinnedModels: pinnedModels });
		await updateUserSettings(localStorage.token, { ui: $settings });
	};

	$: if (selectedModels.length > 0 && $models.length > 0) {
		const _selectedModels = selectedModels.map((model) =>
			$models.map((m) => m.id).includes(model) ? model : ''
		);

		if (JSON.stringify(_selectedModels) !== JSON.stringify(selectedModels)) {
			selectedModels = _selectedModels;
		}
	}

	// Convert $models to items format for Selector component
	$: items = $models.map((model) => ({
		label: model.name ?? model.id,
		value: model.id,
		model: model
	}));
</script>

<div class="flex flex-col w-full items-start">
	<div class="flex w-full max-w-fit">
		<div class="overflow-hidden w-full">
			<div class="max-w-full {($settings?.highContrastMode ?? false) ? 'm-1' : 'mr-1'}">
				<Selector
					{items}
					bind:selectedModels
					{disabled}
					on:change
					on:pin={async (e) => {
						await pinModelHandler(e.detail);
					}}
				/>
			</div>
		</div>
	</div>

	{#if showSetDefault && selectedModels.length > 0}
		<div class="flex items-center gap-0.5 -mt-0.5 mx-1.5">
			<Tooltip content={$i18n.t('Set as default')} placement="bottom-start">
				<button
					class="text-left px-2 py-1 text-xs font-medium bg-transparent hover:bg-gray-50 dark:hover:bg-gray-850 transition rounded-full"
					on:click={() => {
						saveDefaultModel();
					}}
				>
					{$i18n.t('Set as default')}
				</button>
			</Tooltip>
		</div>
	{/if}
</div>
