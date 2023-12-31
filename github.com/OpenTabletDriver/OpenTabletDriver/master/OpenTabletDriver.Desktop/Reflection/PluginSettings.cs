using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Reflection;
using JetBrains.Annotations;
using Newtonsoft.Json;
using OpenTabletDriver.Attributes;

namespace OpenTabletDriver.Desktop.Reflection
{
    [UsedImplicitly(ImplicitUseTargetFlags.Members)]
    public class PluginSettings
    {
        public PluginSettings(Type type, bool enable = true)
        {
            Path = type.FullName!;
            Settings = GetSettingsForType(type);
            Enable = enable;
        }

        public PluginSettings(Type type, IEnumerable<PluginSetting> settings, bool enable = true)
        {
            Path = type.FullName!;
            Settings = new ObservableCollection<PluginSetting>(settings);
            Enable = enable;
        }

        public PluginSettings(Type type, object settings, bool enable = true)
        {
            Path = type.FullName!;
            Settings = GetSettingsFromObject(settings);
            Enable = enable;
        }

        [JsonConstructor]
        private PluginSettings()
        {
        }

        public string Path { set; get; } = string.Empty;

        public ObservableCollection<PluginSetting> Settings { get; } = new ObservableCollection<PluginSetting>();

        public bool Enable { set; get; }

        public PluginSetting this[string propertyName]
        {
            set
            {
                if (Settings.FirstOrDefault(t => t.Property == propertyName) is PluginSetting setting)
                {
                    Settings.Remove(setting);
                    Settings.Add(value);
                }
                else
                {
                    Settings.Add(value);
                }
            }
            get
            {
                var result = Settings.FirstOrDefault(s => s.Property == propertyName);
                if (result == null)
                {
                    var newSetting = new PluginSetting(propertyName, new object());
                    Settings!.Add(newSetting);
                    return newSetting;
                }
                return result;
            }
        }

        public override string ToString()
        {
            return base.ToString() + ": " + Path;
        }

        private static ObservableCollection<PluginSetting> GetSettingsForType(Type targetType, object? source = null)
        {
            var settings = from property in targetType.GetProperties()
                where property.GetCustomAttribute<SettingAttribute>() != null
                select new PluginSetting(property, source == null ? null : property.GetValue(source));

            return new ObservableCollection<PluginSetting>(settings);
        }

        private static ObservableCollection<PluginSetting> GetSettingsFromObject(object obj)
        {
            var type = obj.GetType();
            if (type.IsAssignableTo(typeof(PluginSettings)))
            {
                throw new ArgumentException(
                    $"Attempted to generate settings from a {nameof(PluginSettings)}.",
                    nameof(obj)
                );
            }

            var settings = from property in type.GetProperties()
                let name = property.Name
                let value = property.GetValue(obj)
                select new PluginSetting(name, value);

            return new ObservableCollection<PluginSetting>(settings);
        }
    }
}
