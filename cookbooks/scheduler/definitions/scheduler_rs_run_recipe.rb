# Copyright 2010, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

define :scheduler_rs_run_recipe, :json_file => nil, :frequency => 'daily', :action => 'schedule' do
  # Grab the existing list of recipes from the appropriate frequency attribute
  recipe_list = case params[:frequency]
    when 'hourly'   then node[:scheduler][:hourly_recipes]
    when 'daily'    then node[:scheduler][:daily_recipes]
    #when 'weekly'   then node[:scheduler][:weekly_recipes]
    #when 'monthly'  then node[:scheduler][:monthly_recipes]
  end

  # Modify the list
  modded_recipe_list = recipe_list
  if params[:action] == 'schedule'
    modded_recipe_list += [{"recipe" => params[:name], "json_file" => params[:json_file]}]
  else
    modded_recipe_list -= [{"recipe" => params[:name], "json_file" => params[:json_file]}]
  end

  # Push the list of recipes back into the node attribute
  case params[:frequency]
    when 'hourly'   then recipe_list = node[:scheduler][:hourly_recipes]  = modded_recipe_list.uniq
    when 'daily'    then recipe_list = node[:scheduler][:daily_recipes]   = modded_recipe_list.uniq
    #when 'weekly'   then recipe_list = node[:scheduler][:weekly_recipes]  = modded_recipe_list.uniq
    #when 'monthly'  then recipe_list = node[:scheduler][:monthly_recipes] = modded_recipe_list.uniq
  end

  template ::File.join(node[:scheduler][:script_dir], params[:frequency], "rs_run_recipe#{node[:scheduler][:script_ext]}") do
    source "schedule_rs_run_recipe.erb"
    backup false
    action :create
  end
end