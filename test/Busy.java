import java.util.concurrent.atomic.AtomicLong;

class Busy {
  private static AtomicLong counter = new AtomicLong(0);

  private static void eatCpu(int stackDepth) {
    if (stackDepth == 0) {
      long dummy = 14;
      for (int i = 0; i < 1000; ++i) {
        dummy *= i;
      }
      counter.incrementAndGet();
    } else {
      eatCpu(stackDepth - 1);
    }
  }

  public static void main(String[] args) throws Exception {
    if (args.length < 3) {
      System.err.println(
          "USAGE: java Busy <num-threads> <stack-depth> <time-seconds>");
      System.exit(1);
    }

    final int numThreads = Integer.parseInt(args[0]);
    final int stackDepth = Integer.parseInt(args[1]);
    int timeTicks = Integer.parseInt(args[2]) * 4;

    Thread[] threads = new Thread[numThreads];
    for (int i = 0; i < numThreads; ++i) {
      threads[i] = new Thread(new Runnable() {
        @Override
        public void run() {
          while (true) {
            eatCpu(stackDepth);
          }
        }
      });
      threads[i].start();
    }

    long previous = counter.get();
    long start = System.currentTimeMillis();
    while (timeTicks >= 0) {
      Thread.sleep(250);
      long current = counter.get();
      long now = System.currentTimeMillis();
      System.err.println((current - previous) / (float)(now - start));
      previous = current;
      start = now;
      timeTicks--;
    }
    System.exit(0);
  }
}
