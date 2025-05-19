int count;
float scale_factor;
char initial_val;

int another_global_var;

count = 100;
scale_factor = 0.5;
initial_val = 65;

if (count > 50) {
    int local_val;
    char count; 
    local_val = 10;
    count = 66; 
    scale_factor = scale_factor * 2.0;
}
another_global_var = count + 5;