#include <dispenso/parallel_for.h>
#include <dispenso/task_set.h>
#include <dispenso/thread_pool.h>

#include <atomic>
#include <cstddef>
#include <numeric>
#include <vector>

int main() {
  constexpr std::size_t kCount = 128;
  std::vector<int> values(kCount, 0);

  dispenso::parallel_for(std::size_t{0}, kCount, [&](std::size_t index) {
    values[index] = static_cast<int>(index * index);
  });

  const int sum = std::accumulate(values.begin(), values.end(), 0);
  int expected = 0;
  for (std::size_t index = 0; index < kCount; ++index) {
    expected += static_cast<int>(index * index);
  }
  if (sum != expected) {
    return 1;
  }

  std::atomic<int> completed{0};
  dispenso::TaskSet tasks(dispenso::globalThreadPool());
  for (int index = 0; index < 8; ++index) {
    tasks.schedule([&completed]() {
      completed.fetch_add(1);
    });
  }
  tasks.wait();

  return completed.load() == 8 ? 0 : 2;
}
