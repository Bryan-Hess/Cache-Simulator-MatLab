%% MASTER LIST FOR FINAL TEST CASES
clear; 
clc;
close all; 

%Configurable Parameters for Simulation
%1.) Number of cache layers
%2.) Size of each layer
%3.) Access Latency for each layer
%4.) Block Size in bytes (same for all layers)
%5.) Set associativity for each layer
%6.) Write Policy
%   a.)1 = write-back+write-allocate
%   b.)2 = write-through+non-write-allocate

%Configuration Parameters Format:
%{#cacheLayers,[layerSize,latency,blockSize,associativity,policy],[]...}
config = {2;[32000, 1, 64, 4, 1];[64000, 50, 64, 8, 1]};

% Define cache objects
Cache = Simulation(config);


%Instruction format
%('r/w', tag, L2-L1_Index, L1_Index, Cycle)
%NOTE: There is no offset, this is because we take the values directly in
%as decimals. There is no need for the offset
%NOTE: All addresses are increased by 1 as matlab starts indexing at 1
%NOTE: Can add varaible cache indexes, however must follow format:
%(...NormalInstructionFormat, [L3Index, L4Index, ...])
%% Warmup
fprintf("\nWARM UP\n")
Cache.run('r', 408, 2, 55, 1);
Cache.run('r', 409, 2, 55, 2);
Cache.run('r', 410, 2, 55, 3);
Cache.run('r', 411, 2, 55, 4);
Cache.run('r', 412, 2, 55, 5);
Cache.run('r', 413, 2, 55, 6);
Cache.run('r', 414, 2, 55, 7);
Cache.run('r', 415, 2, 55, 8);
Cache.run('r', 416, 2, 55, 9);
Cache.run('r', 417, 2, 55, 10);
Cache.run('r', 418, 2, 55, 11);
Cache.run('r', 419, 2, 55, 12);
Cache.run('r', 420, 2, 55, 13);
Cache.run('r', 421, 2, 55, 14);
Cache.run('r', 422, 2, 55, 15);
Cache.run('r', 423, 2, 55, 16);
Cache.run('r', 408, 3, 55, 17);
Cache.run('r', 409, 3, 55, 18);
Cache.run('r', 410, 3, 55, 19);
Cache.run('r', 411, 3, 55, 20);
Cache.run('r', 412, 3, 55, 21);
Cache.run('r', 413, 3, 55, 22);
Cache.run('r', 414, 3, 55, 23);
Cache.run('r', 415, 3, 55, 24);
Cache.run('r', 416, 3, 55, 25);
Cache.run('r', 417, 3, 55, 26);
Cache.run('r', 418, 3, 55, 27);
Cache.run('r', 419, 3, 55, 28);
Cache.run('r', 420, 3, 55, 29);
Cache.run('r', 421, 3, 55, 30);
Cache.run('r', 422, 3, 55, 31);
Cache.run('r', 423, 3, 55, 32);

%% Case 1: Random Read
fprintf("\nRANDOM READ\n")
Cache.run('r', 423, 3, 55, 10000);
Cache.run('r', 417, 3, 55, 10001);
Cache.run('r', 417, 3, 55, 10002);
Cache.run('r', 423, 3, 55, 10152);
Cache.run('r', 416, 2, 55, 10153);
Cache.run('r', 414, 3, 55, 10154);
Cache.run('r', 422, 3, 55, 10304);
Cache.run('r', 418, 3, 55, 10305);
Cache.run('r', 413, 3, 55, 10306);
Cache.run('r', 417, 2, 55, 10456);
Cache.run('r', 431, 4, 55, 10457);
Cache.run('r', 431, 3, 55, 10458);
Cache.run('r', 429, 4, 55, 10459);
Cache.run('r', 424, 3, 55, 10609);
Cache.run('r', 426, 4, 55, 10610);
Cache.run('r', 426, 4, 55, 10611);
Cache.run('r', 430, 3, 55, 10761);
Cache.run('r', 427, 4, 55, 10762);
Cache.run('r', 430, 4, 55, 10763);
Cache.run('r', 428, 3, 55, 10913);

fprintf('\n---End Results---\n')
for i = 1:Cache.CacheNum
    fprintf("%d Hits -- %d Misses -- %d Accesses\nL%d Hit Rate: %.2f%%\nL%d Miss Rate: %.2f%%\n", Cache.Caches(i).TotalHits, Cache.Caches(i).TotalMisses, Cache.Caches(i).TotalAccess, i, (Cache.Caches(i).HitRate * 100), i, (Cache.Caches(i).MissRate * 100))
end
fprintf('-----------------\n')

%% Case 2: Random Read/Write
fprintf("\nRANDOM READ/WRITE\n")
Cache.run('w', 420, 3, 55, 10000);
Cache.run('r', 412, 3, 55, 10001);
Cache.run('w', 417, 2, 55, 10002);
Cache.run('r', 415, 2, 55, 10152);
Cache.run('w', 416, 3, 55, 10153);
Cache.run('r', 416, 2, 55, 10154);
Cache.run('r', 419, 3, 55, 10304);
Cache.run('r', 416, 3, 55, 10305);
Cache.run('w', 412, 2, 55, 10306);
Cache.run('w', 415, 2, 55, 10456);

fprintf('\n---End Results---\n')
for i = 1:Cache.CacheNum
    fprintf("%d Hits -- %d Misses -- %d Accesses\nL%d Hit Rate: %.2f%%\nL%d Miss Rate: %.2f%%\n", Cache.Caches(i).TotalHits, Cache.Caches(i).TotalMisses, Cache.Caches(i).TotalAccess, i, (Cache.Caches(i).HitRate * 100), i, (Cache.Caches(i).MissRate * 100))
end
fprintf('-----------------\n')

%% Test Case 3: Random Write (L2 miss)
fprintf("\nRANDOM WRITE (L2 MISS)\n")
Cache.run('w', 428, 3, 55, 10000);
Cache.run('w', 429, 4, 55, 10001);
Cache.run('r', 428, 4, 55, 10002);
Cache.run('r', 428, 3, 55, 10152);
Cache.run('w', 427, 3, 55, 10153);
Cache.run('r', 424, 3, 55, 10154);
Cache.run('r', 427, 4, 55, 10304);
Cache.run('r', 431, 4, 55, 10305);
Cache.run('w', 426, 4, 55, 10306);
Cache.run('r', 428, 4, 55, 10456);
Cache.run('r', 428, 3, 55, 10457);
Cache.run('w', 427, 4, 55, 10458);
Cache.run('r', 429, 4, 55, 10608);
Cache.run('w', 428, 4, 55, 10609);
Cache.run('w', 428, 4, 55, 10610);

fprintf('\n---End Results---\n')
for i = 1:Cache.CacheNum
    fprintf("%d Hits -- %d Misses -- %d Accesses\nL%d Hit Rate: %.2f%%\nL%d Miss Rate: %.2f%%\n", Cache.Caches(i).TotalHits, Cache.Caches(i).TotalMisses, Cache.Caches(i).TotalAccess, i, (Cache.Caches(i).HitRate * 100), i, (Cache.Caches(i).MissRate * 100))
end
fprintf('-----------------\n')
