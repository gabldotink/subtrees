using System.Linq.Expressions;
using Eto.Drawing;
using Eto.Forms;
using OpenTabletDriver.Desktop.Profiles;
using OpenTabletDriver.Output;

namespace OpenTabletDriver.UX.Controls.Editors
{
    public class InputAreaDisplay : AreaDisplay
    {
        private readonly App _app;
        private IList<RectangleF>? _backgrounds;

        public InputAreaDisplay(App app)
        {
            _app = app;

            DataContextChanged += delegate
            {
                _backgrounds = GetBackgrounds();
            };
        }

        protected override string Unit => "mm";
        protected override Expression<Func<AbsoluteOutputMode, Area>> Foreground { get; } = mode => mode.Input!;
        protected override IEnumerable<RectangleF> Backgrounds => _backgrounds ??= GetBackgrounds();

        private IList<RectangleF> GetBackgrounds()
        {
            var profile = Parents.Select(w => w as IBindable).First(b => b?.DataContext is Profile)!.DataContext as Profile;
            var tablet = _app.Tablets.First(t => t.Name == profile!.Tablet);
            var digitizer = tablet.Specifications.Digitizer!;
            return new []
            {
                new RectangleF(0, 0, digitizer.Width, digitizer.Height)
            };
        }
    }
}
