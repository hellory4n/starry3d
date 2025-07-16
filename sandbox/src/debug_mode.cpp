#include <trippin/memory.hpp>
#include <starry/window.hpp>
#include <starry/imgui.hpp>

#include "debug_mode.hpp"

void sandbox::debug_mode()
{
	ImGui::Begin("Debug Mode");

	ImGui::Text("Time:");
		ImGui::BulletText("FPS: %.0f", st::fps());

	tr::MemoryInfo memory = tr::get_memory_info();
	ImGui::Text("Memory:");
		ImGui::BulletText("Arena memory: %zi MB", tr::bytes_to_mb(memory.allocated));
		ImGui::BulletText("Pages: %zi", memory.alive_pages);

	ImGui::Text("Cumulative:");
		ImGui::BulletText("Arena memory: %zi MB", tr::bytes_to_mb(memory.cumulative_allocated));
		ImGui::BulletText("Pages: %zi", memory.cumulative_pages);

	ImGui::Text("Freed:");
		ImGui::BulletText("Arena memory: %zi MB", tr::bytes_to_mb(memory.freed_by_arenas));
		ImGui::BulletText("Pages: %zi", memory.freed_pages);

	ImGui::End();
}