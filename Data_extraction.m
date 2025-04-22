%%%提取指定目录下所有mat文件，合并保存。mat文件格式名必须为断层名_断层编号_quakes.mat

%%%输出为断层编号、三个主应力轴参数、形状比R值大小、摩擦系数；31行为指定提取的变量名称


clear all;close all;clc;
% 设置数据文件夹路径
data_folder = '应力场批量处理（Varycuk）\Output'; % 修改为你的实际路径
files = dir(fullfile(data_folder, '*_quakes.mat'));

% 初始化结果变量
new_data = [];

% 遍历所有符合条件的 .mat 文件
for i = 1:length(files)
    file_name = files(i).name;
    file_path = fullfile(data_folder, file_name);

    % 从文件名提取断层编号（假设命名规则为 faultName_faultID_quakes.mat）
    tokens = split(file_name, '_');
    if length(tokens) < 3
        warning('文件名格式不符合要求：%s', file_name);
        continue;
    end
    fault_id = str2double(tokens{2}); % 第二个部分是编号

    % 加载 .mat 文件
    data = load(file_path);

    % 确保所需变量存在
    required_fields = {'sigma_1','sigma_2','sigma_3','shape_ratio','friction'};
    if ~all(isfield(data, required_fields))
        warning('文件中缺少必要变量：%s', file_name);
        continue;
    end

    % 提取数据（确保是列向量或标量）
    s1 = data.sigma_1(:);
    s2 = data.sigma_2(:);
    s3 = data.sigma_3(:);
    R  = data.shape_ratio;
    fr = data.friction;

    % 构建一行数据：[编号 s1(1) s1(2) s2(1) s2(2) s3(1) s3(2) R friction]
    row = [fault_id, s1.azimuth, s1.plunge, s2.azimuth, s2.plunge, s3.azimuth, s3.plunge, R, fr];

    % 添加到总结果
    new_data = [new_data; row];
end

% 可选：显示结果
% disp('汇总数据（new_data）:');
% disp(new_data);
xlswrite('merge_stress.xlsx',new_data);