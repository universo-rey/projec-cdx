def test_reports_dependencies_available():
    import matplotlib
    import reportlab

    assert matplotlib.__version__
    assert reportlab.Version
